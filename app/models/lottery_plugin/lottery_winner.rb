module LotteryPlugin
  class LotteryWinner < ActiveRecord::Base
    self.table_name = "lottery_plugin_winners"

    # 关联关系
    belongs_to :lottery, class_name: "LotteryPlugin::Lottery"
    belongs_to :user

    # 校验规则
    validates :lottery_id, presence: true
    validates :user_id, presence: true
    validates :rank, presence: true, uniqueness: { scope: :lottery_id }
    validates :won_at, presence: true

    # 作用域
    scope :by_rank, -> { order(:rank) }
    scope :for_lottery, ->(lottery_id) { where(lottery_id: lottery_id) }

    # 获奖等级名称
    def rank_name
      case rank
      when 1
        I18n.t("lottery.ranks.first_prize")
      when 2
        I18n.t("lottery.ranks.second_prize")
      when 3
        I18n.t("lottery.ranks.third_prize")
      else
        I18n.t("lottery.ranks.nth_prize", rank: rank)
      end
    end

    # 获奖等级简称
    def rank_short_name
      case rank
      when 1
        I18n.t("lottery.ranks.first")
      when 2
        I18n.t("lottery.ranks.second")
      when 3
        I18n.t("lottery.ranks.third")
      else
        I18n.t("lottery.ranks.nth", rank: rank)
      end
    end
  end
end
