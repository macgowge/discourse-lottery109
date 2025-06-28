import { apiInitializer } from "discourse/lib/api";
import I18n from "discourse-i18n";
// import { h } from "virtual-dom"; // 如果需要用 virtual-dom 创建元素

export default apiInitializer("1.0.1", (api) => { // 版本化您的初始化器
  // 使用 Discourse 的模态服务显示警报的辅助函数
  const showAlert = (message, type = 'error') => {
    const modal = api.container.lookup("service:modal");
    if (modal && modal.alert) {
      modal.alert({ message, type }); // type 可以是 'error', 'success', 'warning'
    } else {
      window.alert(message); // 回退
    }
  };

  // 更新抽奖框状态显示的函数
  function updateStatusDisplay(box, currentEntries, maxEntries, prizeName, pointsCost, prizeCount = 1) {
    const statusDiv = box.querySelector(".lottery-status-display");
    if (!statusDiv) return;

    let entriesText;
    if (maxEntries && maxEntries > 0) {
      const remaining = Math.max(0, maxEntries - currentEntries);
      entriesText = I18n.t("js.lottery.status_limited", {
        current: currentEntries,
        total: maxEntries,
        remaining: remaining,
      });
    } else {
      entriesText = I18n.t("js.lottery.status_unlimited", { count: currentEntries });
    }

    const costText = pointsCost > 0 ? I18n.t("js.lottery.cost_info", { cost: pointsCost }) : I18n.t("js.lottery.cost_free");

    statusDiv.innerHTML = ''; // 清除现有内容

    const prizeElement = document.createElement("div");
    prizeElement.className = "lottery-prize";
    if (prizeCount > 1) {
      prizeElement.textContent = I18n.t("js.lottery.prize_with_count", {
        prizeName: prizeName || I18n.t("js.lottery.default_prize"),
        count: prizeCount
      });
    } else {
      prizeElement.textContent = I18n.t("js.lottery.prize", { prizeName: prizeName || I18n.t("js.lottery.default_prize") });
    }

    const statsElement = document.createElement("div");
    statsElement.className = "lottery-stats";
    statsElement.textContent = entriesText;

    const costElement = document.createElement("div");
    costElement.className = "lottery-cost";
    costElement.textContent = costText;

    statusDiv.append(prizeElement, statsElement, costElement);
  }

  // 倒计时函数
  function startCountdown(countdownDiv, autoDrawAt, lotteryBox) {
    const targetTime = new Date(autoDrawAt).getTime();

    function updateCountdown() {
      const now = new Date().getTime();
      const timeLeft = targetTime - now;

      if (timeLeft <= 0) {
        countdownDiv.innerHTML = `⏰ ${I18n.t("js.lottery.auto_draw_time_up")}`;
        countdownDiv.className = "lottery-countdown-display lottery-countdown-expired";

        // 可以在这里添加自动刷新逻辑
        setTimeout(() => {
          window.location.reload();
        }, 3000);
        return;
      }

      const days = Math.floor(timeLeft / (1000 * 60 * 60 * 24));
      const hours = Math.floor((timeLeft % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
      const minutes = Math.floor((timeLeft % (1000 * 60 * 60)) / (1000 * 60));
      const seconds = Math.floor((timeLeft % (1000 * 60)) / 1000);

      let timeText = "";
      if (days > 0) {
        timeText = I18n.t("js.lottery.countdown_days", { days, hours, minutes, seconds });
      } else if (hours > 0) {
        timeText = I18n.t("js.lottery.countdown_hours", { hours, minutes, seconds });
      } else if (minutes > 0) {
        timeText = I18n.t("js.lottery.countdown_minutes", { minutes, seconds });
      } else {
        timeText = I18n.t("js.lottery.countdown_seconds", { seconds });
      }

      countdownDiv.innerHTML = `⏰ ${I18n.t("js.lottery.auto_draw_in")} ${timeText}`;
      countdownDiv.className = "lottery-countdown-display";
    }

    // 立即更新一次
    updateCountdown();

    // 每秒更新
    const interval = setInterval(updateCountdown, 1000);

    // 存储 interval ID 以便清理
    lotteryBox.countdownInterval = interval;
  }


  api.decorateCookedElement((cookedElem, postDecorator) => {
    if (!postDecorator) return;

    const post = postDecorator.getModel();
    if (!post || !post.id) return;

    const lotteryData = post.lottery_data;

    if (lotteryData && lotteryData.id) {
      let lotteryBox = cookedElem.querySelector(`.lottery-box[data-lottery-id="${lotteryData.id}"]`);

      if (!lotteryBox) {
         let placeholder = cookedElem.querySelector('.lottery-placeholder-for-post-' + post.id);
         if (!placeholder) {
            placeholder = document.createElement('div');
            // 给这个自动创建的 div 一个更明确的类名，以便调试和可能的特定样式
            placeholder.className = `lottery-box auto-created-lottery-box lottery-placeholder-for-post-${post.id}`;
            cookedElem.appendChild(placeholder);
         }
         lotteryBox = placeholder;
         lotteryBox.dataset.lotteryId = lotteryData.id;
      }

      if (lotteryBox.dataset.lotteryInitialized === "true") return;
      lotteryBox.dataset.lotteryInitialized = "true";

      lotteryBox.dataset.prizeName = lotteryData.prize_name || I18n.t("js.lottery.default_prize");
      lotteryBox.dataset.pointsCost = lotteryData.points_cost;
      lotteryBox.dataset.maxEntries = lotteryData.max_entries || "";
      lotteryBox.dataset.totalEntries = lotteryData.total_entries;
      lotteryBox.dataset.lotteryTitle = lotteryData.title || I18n.t("js.lottery.default_title");
      lotteryBox.dataset.lotteryStatus = lotteryData.status || 'active';
      lotteryBox.dataset.winnerId = lotteryData.winner_id || '';
      lotteryBox.dataset.winnerUsername = lotteryData.winner_username || '';
      lotteryBox.dataset.prizeCount = lotteryData.prize_count || 1;
      lotteryBox.dataset.multiplePrizes = lotteryData.multiple_prizes || false;
      lotteryBox.dataset.autoDrawEnabled = lotteryData.auto_draw_enabled || false;
      lotteryBox.dataset.autoDrawAt = lotteryData.auto_draw_at || '';

      lotteryBox.innerHTML = ''; // 清除占位符内容

      const lotteryId = lotteryData.id;
      const cost = parseInt(lotteryData.points_cost, 10) || 0;
      const maxEntries = lotteryData.max_entries ? parseInt(lotteryData.max_entries, 10) : null;
      let currentEntries = parseInt(lotteryData.total_entries, 10) || 0;
      const prizeName = lotteryData.prize_name;
      const lotteryTitle = lotteryData.title;
      const lotteryStatus = lotteryData.status || 'active';
      const winnerId = lotteryData.winner_id;
      const winnerUsername = lotteryData.winner_username;
      const prizeCount = parseInt(lotteryData.prize_count, 10) || 1;
      const multiplePrizes = lotteryData.multiple_prizes;
      const winners = lotteryData.winners || [];
      const autoDrawEnabled = lotteryData.auto_draw_enabled;
      const autoDrawAt = lotteryData.auto_draw_at;

      const container = document.createElement("div");
      container.className = "lottery-ui-container";

      const titleElement = document.createElement("h3");
      titleElement.className = "lottery-title-display";
      titleElement.textContent = lotteryTitle || I18n.t("js.lottery.default_title");
      container.appendChild(titleElement);

      const statusDisplay = document.createElement("div");
      statusDisplay.className = "lottery-status-display";
      container.appendChild(statusDisplay);

      updateStatusDisplay(lotteryBox, currentEntries, maxEntries, prizeName, cost, prizeCount);

      // 显示自动开奖倒计时
      if (autoDrawEnabled && autoDrawAt && lotteryStatus === 'active') {
        const countdownDiv = document.createElement("div");
        countdownDiv.className = "lottery-countdown-display";
        container.appendChild(countdownDiv);

        // 启动倒计时
        startCountdown(countdownDiv, autoDrawAt, lotteryBox);
      }

      // 显示抽奖状态和获奖者信息
      if (lotteryStatus === 'completed') {
        if (multiplePrizes && winners.length > 0) {
          // 多奖品显示
          const winnersDiv = document.createElement("div");
          winnersDiv.className = "lottery-winners-display";

          const titleDiv = document.createElement("div");
          titleDiv.className = "lottery-winners-title";
          titleDiv.innerHTML = `🎉 ${I18n.t("js.lottery.winners_announced", { count: winners.length })}`;
          winnersDiv.appendChild(titleDiv);

          const winnersList = document.createElement("div");
          winnersList.className = "lottery-winners-list";

          winners.forEach(winner => {
            const winnerItem = document.createElement("div");
            winnerItem.className = "lottery-winner-item";
            winnerItem.innerHTML = `
              <span class="winner-rank">${winner.rank_name}</span>
              <span class="winner-username">@${winner.username}</span>
            `;
            winnersList.appendChild(winnerItem);
          });

          winnersDiv.appendChild(winnersList);
          container.appendChild(winnersDiv);
        } else if (winnerUsername) {
          // 单奖品显示
          const winnerDiv = document.createElement("div");
          winnerDiv.className = "lottery-winner-display";
          winnerDiv.innerHTML = `🎉 ${I18n.t("js.lottery.winner_announced", { winner: winnerUsername })}`;
          container.appendChild(winnerDiv);
        }
      } else if (lotteryStatus === 'cancelled') {
        const cancelledDiv = document.createElement("div");
        cancelledDiv.className = "lottery-cancelled-display";
        cancelledDiv.innerHTML = `❌ ${I18n.t("js.lottery.lottery_cancelled")}`;
        container.appendChild(cancelledDiv);
      }

      // 参与按钮（只在活跃状态显示）
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
      }

      // 管理员开奖按钮
      const currentUser = api.getCurrentUser();
      let adminButton = null;
      if (currentUser && currentUser.admin && lotteryStatus === 'active' && currentEntries > 0) {
        adminButton = document.createElement("button");
        adminButton.className = "btn btn-danger admin-draw-btn";
        adminButton.innerHTML = I18n.t("js.lottery.admin_draw_btn");
        adminButton.style.marginLeft = "10px";
      }

      const messageArea = document.createElement("div");
      messageArea.className = "lottery-message-area";
      // container.appendChild(messageArea); // 移动到按钮之后添加

      // 参与按钮事件
      if (button) {
        button.addEventListener("click", async () => {
        if (cost > 0) {
          const modal = api.container.lookup("service:modal");
          modal.confirm({
            message: I18n.t("js.lottery.confirm_cost_participation", { cost }),
            didConfirm: async () => {
              await tryJoinLottery();
            }
          });
        } else {
          await tryJoinLottery();
        }
        });
      }

      // 管理员开奖按钮事件
      if (adminButton) {
        adminButton.addEventListener("click", async () => {
          const modal = api.container.lookup("service:modal");
          modal.confirm({
            message: I18n.t("js.lottery.confirm_draw", { entries: currentEntries }),
            didConfirm: async () => {
              await drawLottery();
            }
          });
        });
      }

      async function tryJoinLottery() {
        button.disabled = true;
        messageArea.textContent = I18n.t("js.lottery.joining");
        messageArea.className = "lottery-message-area lottery-processing";

        try {
          // 使用 api.container.lookup("service:csrf").token 获取 CSRF token
          const csrfService = api.container.lookup("service:csrf");
          const token = csrfService ? csrfService.token : null;

          if (!token) {
            // 这个错误消息最好也通过 I18n 处理
            throw new Error(I18n.t("js.lottery.csrf_token_error"));
          }

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
            lotteryBox.dataset.totalEntries = currentEntries;
            updateStatusDisplay(lotteryBox, currentEntries, maxEntries, prizeName, cost, prizeCount);

            if (maxEntries && currentEntries >= maxEntries) {
              button.disabled = true;
              button.innerHTML = I18n.t("js.lottery.max_entries_reached_btn");
            }
            messageArea.textContent = I18n.t("js.lottery.success_message_inline");
            messageArea.className = "lottery-message-area lottery-success";
          } else {
            const errorMessage = data.error || (data.errors && data.errors.join(", ")) || I18n.t("js.lottery.generic_error_client");
            showAlert(errorMessage, 'error');
            messageArea.textContent = errorMessage;
            messageArea.className = "lottery-message-area lottery-error";
            // 只有在不是因为“已参与”或“已满”的错误时才重新启用按钮
            if (response.status !== 403 && response.status !== 422 && !(data.error && data.error.includes(I18n.t("lottery.errors.already_participated")))) {
                 button.disabled = false;
            }
          }
        } catch (e) {
          console.error("Lottery Plugin JS Error:", e);
          const networkErrorMsg = I18n.t("js.lottery.network_error_client");
          showAlert(networkErrorMsg + (e.message ? ` (${e.message})` : ''), 'error');
          messageArea.textContent = networkErrorMsg;
          messageArea.className = "lottery-message-area lottery-error";
          button.disabled = false;
        }
      }

      // 开奖函数
      async function drawLottery() {
        if (adminButton) {
          adminButton.disabled = true;
          adminButton.innerHTML = I18n.t("js.lottery.drawing");
        }
        messageArea.textContent = I18n.t("js.lottery.drawing");
        messageArea.className = "lottery-message-area lottery-processing";

        try {
          const csrfService = api.container.lookup("service:csrf");
          const token = csrfService ? csrfService.token : null;

          if (!token) {
            throw new Error(I18n.t("js.lottery.csrf_token_error"));
          }

          const response = await fetch(`/lottery_plugin/admin/draw/${lotteryId}`, {
            method: "POST",
            headers: {
              "Content-Type": "application/json",
              "X-CSRF-Token": token,
            }
          });

          const data = await response.json();

          if (response.ok && data.success) {
            // 更新显示
            if (data.lottery && data.lottery.winners && data.lottery.winners.length > 1) {
              // 多个获奖者
              const winnersDiv = document.createElement("div");
              winnersDiv.className = "lottery-winners-display";

              const titleDiv = document.createElement("div");
              titleDiv.className = "lottery-winners-title";
              titleDiv.innerHTML = `🎉 ${I18n.t("js.lottery.winners_announced", { count: data.lottery.winners.length })}`;
              winnersDiv.appendChild(titleDiv);

              const winnersList = document.createElement("div");
              winnersList.className = "lottery-winners-list";

              data.lottery.winners.forEach(winner => {
                const winnerItem = document.createElement("div");
                winnerItem.className = "lottery-winner-item";
                winnerItem.innerHTML = `
                  <span class="winner-rank">${winner.rank_name}</span>
                  <span class="winner-username">@${winner.username}</span>
                `;
                winnersList.appendChild(winnerItem);
              });

              winnersDiv.appendChild(winnersList);
              container.appendChild(winnersDiv);
            } else {
              // 单个获奖者
              const winnerDiv = document.createElement("div");
              winnerDiv.className = "lottery-winner-display";
              winnerDiv.innerHTML = `🎉 ${I18n.t("js.lottery.winner_announced", { winner: data.winner.username })}`;
              container.appendChild(winnerDiv);
            }

            // 移除参与按钮和管理员按钮
            if (button) button.remove();
            if (adminButton) adminButton.remove();

            showAlert(data.message || I18n.t("js.lottery.draw_success"), 'success');
            messageArea.textContent = I18n.t("js.lottery.draw_completed");
            messageArea.className = "lottery-message-area lottery-success";
          } else {
            const errorMessage = data.error || I18n.t("js.lottery.draw_failed");
            showAlert(errorMessage, 'error');
            messageArea.textContent = errorMessage;
            messageArea.className = "lottery-message-area lottery-error";
            if (adminButton) {
              adminButton.disabled = false;
              adminButton.innerHTML = I18n.t("js.lottery.admin_draw_btn");
            }
          }
        } catch (e) {
          console.error("Lottery Plugin Draw Error:", e);
          const errorMsg = I18n.t("js.lottery.network_error_client");
          showAlert(errorMsg + (e.message ? ` (${e.message})` : ''), 'error');
          messageArea.textContent = errorMsg;
          messageArea.className = "lottery-message-area lottery-error";
          if (adminButton) {
            adminButton.disabled = false;
            adminButton.innerHTML = I18n.t("js.lottery.admin_draw_btn");
          }
        }
      }

      lotteryBox.appendChild(container);

      // 添加按钮区域
      const buttonArea = document.createElement("div");
      buttonArea.className = "lottery-button-area";
      buttonArea.style.display = "flex";
      buttonArea.style.gap = "10px";
      buttonArea.style.alignItems = "center";

      // 添加参与按钮（如果适用）
      if (button && lotteryStatus === 'active' && !(maxEntries && currentEntries >= maxEntries)) {
        buttonArea.appendChild(button);
      }

      // 添加管理员按钮（如果适用）
      if (adminButton) {
        buttonArea.appendChild(adminButton);
      }

      // 只有在有按钮时才添加按钮区域
      if (buttonArea.children.length > 0) {
        container.appendChild(buttonArea);
      }

      container.appendChild(messageArea); // 消息区域在按钮之后

    }
  }, {
    id: 'discourse-lottery-decorator',
    onlyStream: true
  });
});
