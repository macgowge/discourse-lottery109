module LotteryPlugin
  class AdminController < ::ApplicationController
    requires_plugin LotteryPlugin::PLUGIN_NAME
    before_action :ensure_logged_in
    before_action :ensure_admin

    def draw
      lottery = LotteryPlugin::Lottery.find_by(id: params[:lottery_id])
      
      unless lottery
        return render_json_error(I18n.t("lottery.errors.not_found"), status: 404)
      end

      unless lottery.can_draw?
        error_msg = if lottery.completed?
          I18n.t("lottery.errors.already_completed")
        elsif lottery.cancelled?
          I18n.t("lottery.errors.already_cancelled")
        elsif !lottery.entries.exists?
          I18n.t("lottery.errors.no_participants")
        else
          I18n.t("lottery.errors.cannot_draw")
        end
        return render_json_error(error_msg, status: 422)
      end

      if lottery.draw_winner!
        render json: {
          success: true,
          message: I18n.t("lottery.admin.draw_success"),
          winner: {
            id: lottery.winner.id,
            username: lottery.winner.username,
            avatar_url: lottery.winner.avatar_template_url
          },
          lottery: {
            id: lottery.id,
            status: lottery.status,
            drawn_at: lottery.drawn_at,
            total_entries: lottery.entries.count,
            prize_count: lottery.prize_count,
            winners: lottery.formatted_winners,
            multiple_prizes: lottery.multiple_prizes?,
            actual_winner_count: lottery.actual_winner_count
          }
        }, status: :ok
      else
        render_json_error(I18n.t("lottery.errors.draw_failed"), status: 500)
      end
    end

    def cancel
      lottery = LotteryPlugin::Lottery.find_by(id: params[:lottery_id])
      
      unless lottery
        return render_json_error(I18n.t("lottery.errors.not_found"), status: 404)
      end

      unless lottery.active?
        return render_json_error(I18n.t("lottery.errors.cannot_cancel"), status: 422)
      end

      if lottery.cancel!
        render json: {
          success: true,
          message: I18n.t("lottery.admin.cancel_success"),
          lottery: {
            id: lottery.id,
            status: lottery.status
          }
        }, status: :ok
      else
        render_json_error(I18n.t("lottery.errors.cancel_failed"), status: 500)
      end
    end

    def status
      lottery = LotteryPlugin::Lottery.find_by(id: params[:lottery_id])
      
      unless lottery
        return render_json_error(I18n.t("lottery.errors.not_found"), status: 404)
      end

      render json: {
        success: true,
        lottery: {
          id: lottery.id,
          title: lottery.title,
          prize_name: lottery.prize_name,
          status: lottery.status,
          total_entries: lottery.entries.count,
          max_entries: lottery.max_entries,
          points_cost: lottery.points_cost,
          can_draw: lottery.can_draw?,
          winner: lottery.winner ? {
            id: lottery.winner.id,
            username: lottery.winner.username,
            avatar_url: lottery.winner.avatar_template_url
          } : nil,
          drawn_at: lottery.drawn_at,
          created_at: lottery.created_at
        }
      }, status: :ok
    end

    private

    def ensure_admin
      unless current_user&.admin?
        render_json_error(I18n.t("lottery.errors.admin_required"), status: 403)
      end
    end
  end
end
