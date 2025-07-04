import { apiInitializer } from "discourse/lib/api";
import I18n from "discourse-i18n";

export default apiInitializer("1.0.1", (api) => {
  const showAlert = (message, type = 'error') => {
    const modal = api.container.lookup("service:modal");
    if (modal && modal.alert) {
      modal.alert({ message, type });
    } else {
      window.alert(message);
    }
  };

  function getCsrfToken() {
    const meta = document.querySelector('meta[name="csrf-token"]');
    return meta ? meta.getAttribute("content") : null;
  }

  function updateStatusDisplay(box, currentEntries, maxEntries, prizeName, pointsCost, prizeCount = 1) {
    const statusDiv = box.querySelector(".lottery-status-display");
    if (!statusDiv) return;

    let entriesText;
    if (maxEntries && maxEntries > 0) {
      const remaining = Math.max(0, maxEntries - currentEntries);
      entriesText = I18n.t("js.lottery.status_limited", {
        current: currentEntries,
        total: maxEntries,
        remaining,
      });
    } else {
      entriesText = I18n.t("js.lottery.status_unlimited", { count: currentEntries });
    }

    const costText = pointsCost > 0
      ? I18n.t("js.lottery.cost_info", { cost: pointsCost })
      : I18n.t("js.lottery.cost_free");

    statusDiv.innerHTML = "";

    const prizeElement = document.createElement("div");
    prizeElement.className = "lottery-prize";
    prizeElement.textContent = prizeCount > 1
      ? I18n.t("js.lottery.prize_with_count", {
          prizeName: prizeName || I18n.t("js.lottery.default_prize"),
          count: prizeCount
        })
      : I18n.t("js.lottery.prize", {
          prizeName: prizeName || I18n.t("js.lottery.default_prize")
        });

    const statsElement = document.createElement("div");
    statsElement.className = "lottery-stats";
    statsElement.textContent = entriesText;

    const costElement = document.createElement("div");
    costElement.className = "lottery-cost";
    costElement.textContent = costText;

    statusDiv.append(prizeElement, statsElement, costElement);
  }

  function startCountdown(countdownDiv, autoDrawAt, lotteryBox) {
    const targetTime = new Date(autoDrawAt).getTime();

    function updateCountdown() {
      const now = Date.now();
      const timeLeft = targetTime - now;

      if (timeLeft <= 0) {
        countdownDiv.innerHTML = `⏰ ${I18n.t("js.lottery.auto_draw_time_up")}`;
        countdownDiv.className = "lottery-countdown-display lottery-countdown-expired";
        setTimeout(() => window.location.reload(), 3000);
        return;
      }

      const d = Math.floor(timeLeft / (1000 * 60 * 60 * 24));
      const h = Math.floor((timeLeft % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
      const m = Math.floor((timeLeft % (1000 * 60 * 60)) / (1000 * 60));
      const s = Math.floor((timeLeft % (1000 * 60)) / 1000);

      let timeText = "";
      if (d > 0) timeText = I18n.t("js.lottery.countdown_days", { days: d, hours: h, minutes: m, seconds: s });
      else if (h > 0) timeText = I18n.t("js.lottery.countdown_hours", { hours: h, minutes: m, seconds: s });
      else if (m > 0) timeText = I18n.t("js.lottery.countdown_minutes", { minutes: m, seconds: s });
      else timeText = I18n.t("js.lottery.countdown_seconds", { seconds: s });

      countdownDiv.innerHTML = `⏰ ${I18n.t("js.lottery.auto_draw_in")} ${timeText}`;
      countdownDiv.className = "lottery-countdown-display";
    }

    updateCountdown();
    lotteryBox.countdownInterval = setInterval(updateCountdown, 1000);
  }

  api.decorateCookedElement((cookedElem, postDecorator) => {
    if (!postDecorator) return;
    const post = postDecorator.getModel();
    if (!post || !post.id) return;
    const lotteryData = post.lottery_data;
    if (!lotteryData || !lotteryData.id) return;

    let lotteryBox = cookedElem.querySelector(`.lottery-box[data-lottery-id="${lotteryData.id}"]`);
    if (!lotteryBox) {
      let placeholder = cookedElem.querySelector(`.lottery-placeholder-for-post-${post.id}`);
      if (!placeholder) {
        placeholder = document.createElement("div");
        placeholder.className = `lottery-box auto-created-lottery-box lottery-placeholder-for-post-${post.id}`;
        cookedElem.appendChild(placeholder);
      }
      lotteryBox = placeholder;
      lotteryBox.dataset.lotteryId = lotteryData.id;
    }

    if (lotteryBox.dataset.lotteryInitialized === "true") return;
    lotteryBox.dataset.lotteryInitialized = "true";

    const {
      id: lotteryId,
      prize_name,
      points_cost,
      max_entries,
      total_entries,
      title,
      status,
      winner_id,
      winner_username,
      prize_count,
      multiple_prizes,
      auto_draw_enabled,
      auto_draw_at,
      winners
    } = lotteryData;

    const cost = parseInt(points_cost, 10) || 0;
    const maxEntries = max_entries ? parseInt(max_entries, 10) : null;
    let currentEntries = parseInt(total_entries, 10) || 0;
    const prizeName = prize_name;
    const lotteryStatus = status || 'active';
    const prizeCount = parseInt(prize_count, 10) || 1;

    lotteryBox.innerHTML = "";
    const container = document.createElement("div");
    container.className = "lottery-ui-container";

    const titleElement = document.createElement("h3");
    titleElement.className = "lottery-title-display";
    titleElement.textContent = title || I18n.t("js.lottery.default_title");
    container.appendChild(titleElement);

    const statusDisplay = document.createElement("div");
    statusDisplay.className = "lottery-status-display";
    container.appendChild(statusDisplay);
    updateStatusDisplay(lotteryBox, currentEntries, maxEntries, prizeName, cost, prizeCount);

    if (auto_draw_enabled && auto_draw_at && lotteryStatus === 'active') {
      const countdownDiv = document.createElement("div");
      countdownDiv.className = "lottery-countdown-display";
      container.appendChild(countdownDiv);
      startCountdown(countdownDiv, auto_draw_at, lotteryBox);
    }

    const messageArea = document.createElement("div");
    messageArea.className = "lottery-message-area";

    let button = null;
    if (lotteryStatus === 'active') {
      button = document.createElement("button");
      button.className = "btn btn-primary join-lottery-btn";
      button.innerHTML = cost > 0
        ? I18n.t("js.lottery.participate_with_cost_btn", { cost })
        : I18n.t("js.lottery.participate_btn");

      if (maxEntries && currentEntries >= maxEntries) {
        button.disabled = true;
        button.innerHTML = I18n.t("js.lottery.max_entries_reached_btn");
      }

      button.addEventListener("click", async () => {
        if (cost > 0) {
          if (window.confirm(I18n.t("js.lottery.confirm_cost_participation", { cost }))) {
            await tryJoinLottery();
          }
        } else {
          await tryJoinLottery();
        }
      });
    }

    const currentUser = api.getCurrentUser();
    let adminButton = null;
    if (currentUser && currentUser.admin && lotteryStatus === 'active' && currentEntries > 0) {
      adminButton = document.createElement("button");
      adminButton.className = "btn btn-danger admin-draw-btn";
      adminButton.innerHTML = I18n.t("js.lottery.admin_draw_btn");
      adminButton.style.marginLeft = "10px";

      adminButton.addEventListener("click", async () => {
        if (window.confirm(I18n.t("js.lottery.confirm_draw", { entries: currentEntries }))) {
          await drawLottery();
        }
      });
    }

    async function tryJoinLottery() {
      button.disabled = true;
      messageArea.textContent = I18n.t("js.lottery.joining");
      messageArea.className = "lottery-message-area lottery-processing";

      try {
        const token = getCsrfToken();
        if (!token) throw new Error(I18n.t("js.lottery.csrf_token_error"));

        const response = await fetch("/lottery_plugin/entries", {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            "X-CSRF-Token": token,
          },
          body: JSON.stringify({ lottery_id: lotteryId }),
        });

        const data = await response.json();

        if (response.ok && data.success) {
          showAlert(data.message || I18n.t("js.lottery.success_joined_alert"), 'success');
          currentEntries = data.total_entries;
          updateStatusDisplay(lotteryBox, currentEntries, maxEntries, prizeName, cost, prizeCount);
          messageArea.textContent = I18n.t("js.lottery.success_message_inline");
          messageArea.className = "lottery-message-area lottery-success";
          if (maxEntries && currentEntries >= maxEntries) {
            button.disabled = true;
            button.innerHTML = I18n.t("js.lottery.max_entries_reached_btn");
          }
        } else {
          const msg = data.error || (data.errors && data.errors.join(", ")) || I18n.t("js.lottery.generic_error_client");
          showAlert(msg, 'error');
          messageArea.textContent = msg;
          messageArea.className = "lottery-message-area lottery-error";
          if (!msg.includes(I18n.t("lottery.errors.already_participated"))) button.disabled = false;
        }
      } catch (e) {
        console.error("Lottery Plugin JS Error:", e);
        const errMsg = I18n.t("js.lottery.network_error_client") + (e.message ? ` (${e.message})` : '');
        showAlert(errMsg, 'error');
        messageArea.textContent = errMsg;
        messageArea.className = "lottery-message-area lottery-error";
        button.disabled = false;
      }
    }

    async function drawLottery() {
      adminButton.disabled = true;
      adminButton.innerHTML = I18n.t("js.lottery.drawing");
      messageArea.textContent = I18n.t("js.lottery.drawing");
      messageArea.className = "lottery-message-area lottery-processing";

      try {
        const token = getCsrfToken();
        if (!token) throw new Error(I18n.t("js.lottery.csrf_token_error"));

        const response = await fetch(`/lottery_plugin/admin/draw/${lotteryId}`, {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            "X-CSRF-Token": token,
          },
        });

        const data = await response.json();

        if (response.ok && data.success) {
          showAlert(data.message || I18n.t("js.lottery.draw_success"), 'success');
          messageArea.textContent = I18n.t("js.lottery.draw_completed");
          messageArea.className = "lottery-message-area lottery-success";
          if (button) button.remove();
          if (adminButton) adminButton.remove();
          window.location.reload(); // 刷新页面以重新渲染状态
        } else {
          const msg = data.error || I18n.t("js.lottery.draw_failed");
          showAlert(msg, 'error');
          messageArea.textContent = msg;
          messageArea.className = "lottery-message-area lottery-error";
          adminButton.disabled = false;
          adminButton.innerHTML = I18n.t("js.lottery.admin_draw_btn");
        }
      } catch (e) {
        console.error("Lottery Plugin Draw Error:", e);
        const errMsg = I18n.t("js.lottery.network_error_client") + (e.message ? ` (${e.message})` : '');
        showAlert(errMsg, 'error');
        messageArea.textContent = errMsg;
        messageArea.className = "lottery-message-area lottery-error";
        adminButton.disabled = false;
        adminButton.innerHTML = I18n.t("js.lottery.admin_draw_btn");
      }
    }

    const buttonArea = document.createElement("div");
    buttonArea.className = "lottery-button-area";
    buttonArea.style.display = "flex";
    buttonArea.style.gap = "10px";
    buttonArea.style.alignItems = "center";

    if (button) buttonArea.appendChild(button);
    if (adminButton) buttonArea.appendChild(adminButton);
    if (buttonArea.children.length > 0) container.appendChild(buttonArea);
    container.appendChild(messageArea);
    lotteryBox.appendChild(container);
  }, { id: "discourse-lottery-decorator", onlyStream: true });
});
