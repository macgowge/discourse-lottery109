module LotteryPlugin
  class Lottery < ActiveRecord::Base
    self.table_name = "lottery_plugin_lotteries" # 明确设置表名

    # 关联关系
    has_many :entries, class_name: "LotteryPlugin::LotteryEntry", foreign_key: "lottery_id", dependent: :destroy # 抽奖有很多参与记录
    has_many :winners, class_name: "LotteryPlugin::LotteryWinner", foreign_key: "lottery_id", dependent: :destroy # 多个获奖者
    belongs_to :winner, class_name: "User", foreign_key: "winner_user_id", optional: true # 兼容性：第一名获奖者

    # 抽奖状态枚举
    STATUSES = %w[active completed cancelled].freeze

    # 校验规则
    validates :post_id, presence: true, uniqueness: true # 每个帖子只能有一个抽奖
    validates :topic_id, presence: true # 必须关联到主题ID
    validates :title, presence: true, length: { maximum: 255 } # 抽奖标题不能为空，最大长度255
    validates :prize_name, presence: true, length: { maximum: 255 } # 奖品名称不能为空，最大长度255
    validates :points_cost, numericality: { greater_than_or_equal_to: 0, only_integer: true } # 消耗积分必须大于等于0的整数
    validates :max_entries, numericality: { greater_than: 0, only_integer: true, allow_nil: true } # 最大参与人数如果设置，必须是正整数
    validates :prize_count, numericality: { greater_than: 0, only_integer: true } # 奖品个数必须是正整数
    validates :status, inclusion: { in: STATUSES } # 状态必须在允许的值中

    # 作用域
    scope :active, -> { where(status: 'active') }
    scope :completed, -> { where(status: 'completed') }
    scope :cancelled, -> { where(status: 'cancelled') }

    # 状态检查方法
    def active?
      status == 'active'
    end

    def completed?
      status == 'completed'
    end

    def cancelled?
      status == 'cancelled'
    end

    # 是否可以参与
    def can_participate?
      active? && !entries_full? && !expired?
    end

    # 是否已满员
    def entries_full?
      max_entries && entries.count >= max_entries
    end

    # 是否已过期
    def expired?
      end_time && Time.current > end_time
    end

    # 是否应该自动开奖
    def should_auto_draw?
      auto_draw_enabled? &&
      auto_draw_at &&
      Time.current >= auto_draw_at &&
      active? &&
      entries.exists?
    end

    # 是否启用了自动开奖
    def auto_draw_enabled?
      auto_draw_enabled
    end

    # 距离自动开奖还有多长时间
    def time_until_auto_draw
      return nil unless auto_draw_enabled? && auto_draw_at
      return 0 if Time.current >= auto_draw_at

      (auto_draw_at - Time.current).to_i
    end

    # 自动开奖状态文本
    def auto_draw_status_text
      return nil unless auto_draw_enabled? && auto_draw_at

      if Time.current >= auto_draw_at
        if completed?
          I18n.t("lottery.auto_draw.completed")
        else
          I18n.t("lottery.auto_draw.ready")
        end
      else
        time_left = time_until_auto_draw
        if time_left > 86400 # 超过1天
          days = time_left / 86400
          I18n.t("lottery.auto_draw.days_left", count: days.to_i)
        elsif time_left > 3600 # 超过1小时
          hours = time_left / 3600
          I18n.t("lottery.auto_draw.hours_left", count: hours.to_i)
        elsif time_left > 60 # 超过1分钟
          minutes = time_left / 60
          I18n.t("lottery.auto_draw.minutes_left", count: minutes.to_i)
        else
          I18n.t("lottery.auto_draw.seconds_left", count: time_left)
        end
      end
    end

    # 开奖方法
    def draw_winner!
      return false unless can_draw?

      transaction do
        # 获取所有参与者
        all_entries = entries.includes(:user).to_a
        return false if all_entries.empty?

        # 确定实际获奖人数（不能超过参与人数）
        actual_winner_count = [prize_count, all_entries.size].min

        # 随机选择获奖者
        winner_entries = all_entries.sample(actual_winner_count)

        # 清除现有获奖者记录（如果有）
        winners.destroy_all

        # 创建获奖者记录
        winner_entries.each_with_index do |entry, index|
          LotteryPlugin::LotteryWinner.create!(
            lottery: self,
            user: entry.user,
            rank: index + 1,
            won_at: Time.current
          )
        end

        # 为兼容性设置第一名获奖者
        first_winner = winner_entries.first
        update!(
          status: 'completed',
          winner_user_id: first_winner.user_id,
          drawn_at: Time.current
        )

        # 记录日志
        winner_names = winner_entries.map { |e| e.user.username }.join(", ")
        Rails.logger.info "LotteryPlugin: Lottery ##{id} drawn. Winners (#{actual_winner_count}): #{winner_names}"

        # 通知获奖者
        notify_winners

        true
      end
    rescue => e
      Rails.logger.error "LotteryPlugin: Error drawing lottery ##{id}: #{e.message}"
      false
    end

    # 是否可以开奖
    def can_draw?
      active? && entries.exists?
    end

    # 取消抽奖
    def cancel!
      return false unless active?

      update!(status: 'cancelled')
      Rails.logger.info "LotteryPlugin: Lottery ##{id} cancelled"
      true
    end

    # 获取获奖者列表（按排名排序）
    def winner_list
      winners.includes(:user).by_rank
    end

    # 获取获奖者用户名列表
    def winner_usernames
      winner_list.map { |w| w.user.username }
    end

    # 获取格式化的获奖者信息
    def formatted_winners
      winner_list.map do |winner|
        {
          rank: winner.rank,
          rank_name: winner.rank_short_name,
          user_id: winner.user.id,
          username: winner.user.username,
          avatar_url: winner.user.avatar_template_url
        }
      end
    end

    # 是否为多奖品抽奖
    def multiple_prizes?
      prize_count > 1
    end

    # 获奖者数量
    def actual_winner_count
      winners.count
    end

    private

    # 通知获奖者（可以扩展）
    def notify_winners
      winners.each do |winner|
        Rails.logger.info "LotteryPlugin: Notifying winner User ##{winner.user_id} (Rank #{winner.rank}) for lottery ##{id}"
        # 这里可以添加通知逻辑，比如发送私信、邮件等
      end
    end
  end
end
