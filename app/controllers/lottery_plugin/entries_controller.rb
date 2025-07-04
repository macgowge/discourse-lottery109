module LotteryPlugin
  class EntriesController < ::ApplicationController
    requires_plugin LotteryPlugin::PLUGIN_NAME
    before_action :ensure_logged_in
    skip_before_action :verify_authenticity_token, only: [:create]

    def create
      lottery = LotteryPlugin::Lottery.find_by(id: params[:lottery_id])
      unless lottery
        return render json: { success: false, error: I18n.t("lottery.errors.not_found") }, status: 404
      end

      if lottery.max_entries && lottery.entries.count >= lottery.max_entries
        return render json: { success: false, error: I18n.t("lottery.errors.reached_max_entries") }, status: 403
      end

      if lottery.points_cost > 0
        unless current_user.respond_to?(:can_award_self?) && current_user.can_award_self?(-lottery.points_cost)
          return render json: {
            success: false,
            error: I18n.t("lottery.errors.insufficient_points", cost: lottery.points_cost)
          }, status: 402
        end
      end

      entry = LotteryPlugin::LotteryEntry.new(lottery: lottery, user: current_user)

      ActiveRecord::Base.transaction do
        if lottery.points_cost > 0 && current_user.respond_to?(:award_points)
          reason = I18n.t("lottery.points_deduction_reason", title: ActionController::Base.helpers.sanitize(lottery.title))
          current_user.award_points(
            -lottery.points_cost,
            awarded_by: Discourse.system_user,
            reason: reason
          )
          current_user.save!
        end

        unless entry.save
          return render json: { success: false, error: entry.errors.full_messages.join(", ") }, status: 422
        end
      end

      remaining_entries = lottery.max_entries ? lottery.max_entries - lottery.entries.reload.count : nil

      render json: {
        success: true,
        message: I18n.t("lottery.success_joined"),
        remaining_entries: remaining_entries,
        total_entries: lottery.entries.count
      }, status: :created

    rescue ActiveRecord::RecordInvalid => e
      render json: { success: false, error: e.record.errors.full_messages.join(", ") }, status: 422
    rescue ActiveRecord::Rollback => e
      render json: { success: false, error: e.message || I18n.t("lottery.errors.transaction_failed") }, status: 422
    rescue StandardError => e
      Rails.logger.error "LotteryPlugin EntriesController Error: #{e.message}\n#{e.backtrace.join("\n")}"
      render json: { success: false, error: I18n.t("lottery.errors.generic_error") }, status: 500
    end
  end
end
