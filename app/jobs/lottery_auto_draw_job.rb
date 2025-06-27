class LotteryAutoDrawJob < Jobs::Base
  def execute(args)
    lottery_id = args[:lottery_id]
    
    begin
      lottery = LotteryPlugin::Lottery.find_by(id: lottery_id)
      
      unless lottery
        Rails.logger.error "LotteryAutoDrawJob: Lottery ##{lottery_id} not found"
        return
      end

      Rails.logger.info "LotteryAutoDrawJob: Processing auto draw for lottery ##{lottery_id}"

      # 检查是否应该自动开奖
      unless lottery.should_auto_draw?
        Rails.logger.info "LotteryAutoDrawJob: Lottery ##{lottery_id} should not auto draw. Status: #{lottery.status}, Auto draw enabled: #{lottery.auto_draw_enabled?}, Has entries: #{lottery.entries.exists?}"
        return
      end

      # 执行开奖
      if lottery.draw_winner!
        Rails.logger.info "LotteryAutoDrawJob: Successfully auto-drew lottery ##{lottery_id}. Winner: User ##{lottery.winner_user_id}"
        
        # 发送通知（可选）
        send_auto_draw_notifications(lottery)
      else
        Rails.logger.error "LotteryAutoDrawJob: Failed to auto-draw lottery ##{lottery_id}"
      end

    rescue => e
      Rails.logger.error "LotteryAutoDrawJob: Error processing lottery ##{lottery_id}: #{e.class.name} - #{e.message}\nBacktrace: #{e.backtrace.take(10).join("\n")}"
    end
  end

  private

  def send_auto_draw_notifications(lottery)
    begin
      # 可以在这里添加通知逻辑
      # 例如：给获奖者发私信、给管理员发通知等
      
      if lottery.winner
        Rails.logger.info "LotteryAutoDrawJob: Auto draw completed for lottery ##{lottery.id}. Winner: #{lottery.winner.username}"
        
        # 示例：可以添加系统消息或私信通知
        # SystemMessage.create_from_system_user(
        #   lottery.winner,
        #   :lottery_winner_notification,
        #   lottery_title: lottery.title,
        #   prize_name: lottery.prize_name
        # )
      end
      
    rescue => e
      Rails.logger.error "LotteryAutoDrawJob: Error sending notifications for lottery ##{lottery.id}: #{e.message}"
    end
  end
end
