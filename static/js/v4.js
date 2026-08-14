/* Namma Chennai Explorer V4 - client-side interactivity.
   Built on top of V3; server-side validation remains the final authority. */
(function () {
  "use strict";

  /* ------------------------------------------------------------------ *
   *  Shared helpers
   * ------------------------------------------------------------------ */
  function $(selector, scope) {
    return (scope || document).querySelector(selector);
  }
  function $all(selector, scope) {
    return Array.prototype.slice.call((scope || document).querySelectorAll(selector));
  }
  function formatINR(value) {
    return "₹" + Number(value).toLocaleString("en-IN");
  }
  function debounce(fn, wait) {
    var timer;
    return function () {
      var args = arguments, context = this;
      clearTimeout(timer);
      timer = setTimeout(function () { fn.apply(context, args); }, wait);
    };
  }

  /* ------------------------------------------------------------------ *
   *  1. Budget slider (index page)
   * ------------------------------------------------------------------ */
  function initBudgetSlider() {
    var slider = $("#budget");
    var display = $("#budget-value");
    if (!slider || !display) return;

    function update() {
      var value = parseInt(slider.value, 10) || 0;
      display.textContent = formatINR(value);
      var min = parseInt(slider.min, 10) || 0;
      var max = parseInt(slider.max, 10) || 100;
      var percent = max > min ? ((value - min) / (max - min)) * 100 : 0;
      slider.style.setProperty("--fill", percent + "%");
    }

    slider.addEventListener("input", update);
    update();
  }

  /* ------------------------------------------------------------------ *
   *  2. Interactive duration buttons (index page)
   * ------------------------------------------------------------------ */
  function initDurationButtons() {
    var options = $all(".duration-option");
    var select = $("#duration");
    if (!options.length || !select) return;

    function syncFromSelect() {
      var value = select.value;
      options.forEach(function (btn) {
        var active = btn.getAttribute("data-duration") === value;
        btn.classList.toggle("active", active);
        btn.setAttribute("aria-pressed", active ? "true" : "false");
      });
    }

    options.forEach(function (btn) {
      btn.addEventListener("click", function () {
        select.value = btn.getAttribute("data-duration");
        syncFromSelect();
        // Clear any client-side duration error once a choice is made.
        var error = $("#duration-error");
        if (error) error.remove();
      });
    });

    select.addEventListener("change", syncFromSelect);
    syncFromSelect();
  }

  /* ------------------------------------------------------------------ *
   *  3. Interests - visual feedback (index page)
   *     The checkboxes remain the source of truth; CSS handles styling.
   * ------------------------------------------------------------------ */
  function initInterests() {
    var boxes = $all(".interest-options input[type='checkbox']");
    if (!boxes.length) return;

    boxes.forEach(function (box) {
      box.addEventListener("change", function () {
        var error = $("#interests-error");
        if (error && boxes.some(function (b) { return b.checked; })) error.remove();
      });
    });
  }

  /* ------------------------------------------------------------------ *
   *  4. Search suggestions for starting point (index page)
   * ------------------------------------------------------------------ */
  function initSuggestions() {
    var input = $("#starting_point");
    var list = $("#suggestions");
    if (!input || !list) return;

    var areas = $all("#chennai-areas option").map(function (o) { return o.value; });
    var places = $all("#place-suggestions option").map(function (o) { return o.value; });
    var all = areas.concat(places).filter(function (v, i, arr) {
      return v && arr.indexOf(v) === i;
    });

    var activeIndex = -1;

    function close() {
      list.hidden = true;
      activeIndex = -1;
    }

    function render(filter) {
      var term = (filter || "").trim().toLowerCase();
      var matches = term
        ? all.filter(function (item) { return item.toLowerCase().indexOf(term) !== -1; })
        : all.slice(0, 8);
      if (!matches.length) {
        list.hidden = true;
        return;
      }
      list.innerHTML = "";
      matches.forEach(function (item) {
        var li = document.createElement("li");
        li.textContent = item;
        li.setAttribute("role", "option");
        li.addEventListener("mousedown", function (e) {
          e.preventDefault();
          input.value = item;
          close();
          var error = $("#starting-error");
          if (error) error.remove();
        });
        list.appendChild(li);
      });
      list.hidden = false;
      activeIndex = -1;
    }

    input.addEventListener("input", debounce(function () {
      render(input.value);
    }, 120));

    input.addEventListener("focus", function () {
      if (!input.value) render("");
    });

    input.addEventListener("keydown", function (e) {
      var items = $all("li", list);
      if (list.hidden || !items.length) return;
      if (e.key === "ArrowDown") {
        e.preventDefault();
        activeIndex = (activeIndex + 1) % items.length;
      } else if (e.key === "ArrowUp") {
        e.preventDefault();
        activeIndex = (activeIndex - 1 + items.length) % items.length;
      } else if (e.key === "Enter" && activeIndex >= 0) {
        e.preventDefault();
        input.value = items[activeIndex].textContent;
        close();
      } else if (e.key === "Escape") {
        close();
      }
      items.forEach(function (li, i) {
        li.classList.toggle("active", i === activeIndex);
      });
    });

    document.addEventListener("click", function (e) {
      if (!input.contains(e.target) && !list.contains(e.target)) close();
    });
  }

  /* ------------------------------------------------------------------ *
   *  5. Client-side validation (index page)
   * ------------------------------------------------------------------ */
  function initValidation() {
    var form = $(".planner-form");
    if (!form) return;

    function showError(field, message) {
      var existing = $("#" + field.id + "-error");
      if (existing) existing.remove();
      var error = document.createElement("p");
      error.id = field.id + "-error";
      error.className = "field-error";
      error.textContent = message;
      field.closest(".planner-field, .interest-field").appendChild(error);
    }

    form.addEventListener("submit", function (e) {
      var valid = true;

      var duration = $("#duration");
      if (duration && !duration.value) {
        showError(duration, "Please choose your trip duration.");
        valid = false;
      }

      var budget = $("#budget");
      if (budget) {
        var value = parseInt(budget.value, 10);
        if (isNaN(value) || value <= 0) {
          showError(budget, "Your budget must be greater than ₹0.");
          valid = false;
        }
      }

      var interests = $all(".interest-options input[type='checkbox']");
      if (interests.length && !interests.some(function (b) { return b.checked; })) {
        showError(interests[0], "Select at least one interest so we can personalise your plan.");
        valid = false;
      }

      var start = $("#starting_point");
      if (start && !start.value.trim()) {
        showError(start, "Please enter your starting point.");
        valid = false;
      }

      if (!valid) e.preventDefault();
    });
  }

  /* ------------------------------------------------------------------ *
   *  6. Results page - favorites (localStorage)
   * ------------------------------------------------------------------ */
  var FAV_KEY = "nammaChennaiFavorites";

  function getFavorites() {
    try {
      return JSON.parse(localStorage.getItem(FAV_KEY)) || [];
    } catch (err) {
      return [];
    }
  }
  function saveFavorites(list) {
    try {
      localStorage.setItem(FAV_KEY, JSON.stringify(list));
    } catch (err) {
      /* storage unavailable - ignore */
    }
  }

  function initFavorites() {
    var buttons = $all(".fav-btn");
    if (!buttons.length) return;
    var favorites = getFavorites();

    function refresh() {
      favorites = getFavorites();
      buttons.forEach(function (btn) {
        var id = btn.getAttribute("data-id");
        var active = favorites.indexOf(id) !== -1;
        btn.classList.toggle("active", active);
        btn.setAttribute("aria-pressed", active ? "true" : "false");
        btn.title = active ? "Remove from favourites" : "Add to favourites";
      });
    }

    buttons.forEach(function (btn) {
      btn.addEventListener("click", function () {
        var id = btn.getAttribute("data-id");
        var index = favorites.indexOf(id);
        if (index === -1) {
          favorites.push(id);
        } else {
          favorites.splice(index, 1);
        }
        saveFavorites(favorites);
        refresh();
        // Re-apply active filters so a favourites-only view updates live.
        if (favoritesOnly) applyFilters();
      });
    });

    refresh();
  }

  /* ------------------------------------------------------------------ *
   *  7. Results page - filters
   * ------------------------------------------------------------------ */
  var favoritesOnly = false;

  function initFilters() {
    var categorySelect = $("#filter-category");
    var budgetInput = $("#filter-budget");
    var favToggle = $("#filter-favorites");
    var cards = $all(".recommendation-card");
    if (!cards.length) return;

    function applyFilters() {
      var category = categorySelect ? categorySelect.value : "all";
      var maxCost = budgetInput ? parseInt(budgetInput.value, 10) : Infinity;
      var favorites = getFavorites();

      cards.forEach(function (card) {
        var cardCategory = card.getAttribute("data-category") || "";
        var cardCost = parseInt(card.getAttribute("data-cost") || "0", 10);
        var cardId = card.getAttribute("data-id") || "";
        var showCategory = category === "all" || cardCategory === category;
        var showBudget = cardCost <= maxCost;
        var showFav = !favoritesOnly || favorites.indexOf(cardId) !== -1;
        card.classList.toggle("hidden", !(showCategory && showBudget && showFav));
      });

      var visible = cards.filter(function (c) { return !c.classList.contains("hidden"); }).length;
      var empty = $("#filter-empty");
      if (empty) empty.hidden = visible !== 0;
    }

    if (categorySelect) categorySelect.addEventListener("change", applyFilters);
    if (budgetInput) budgetInput.addEventListener("input", debounce(applyFilters, 120));
    if (favToggle) {
      favToggle.addEventListener("change", function () {
        favoritesOnly = favToggle.checked;
        applyFilters();
      });
    }

    // Expose for favorites live refresh.
    window.__applyFilters = applyFilters;
  }

  /* ------------------------------------------------------------------ *
   *  8. Results page - interactive itinerary (day tabs)
   * ------------------------------------------------------------------ */
  function initItinerary() {
    var tabs = $all(".itinerary-tab");
    var cards = $all(".recommendation-card");
    if (!tabs.length || !cards.length) return;

    function showDay(day) {
      tabs.forEach(function (tab) {
        var active = tab.getAttribute("data-day") === day;
        tab.classList.toggle("active", active);
        tab.setAttribute("aria-selected", active ? "true" : "false");
      });
      cards.forEach(function (card) {
        var cardDay = card.getAttribute("data-day") || "1";
        card.classList.toggle("day-hidden", cardDay !== day);
      });
    }

    tabs.forEach(function (tab) {
      tab.addEventListener("click", function () {
        showDay(tab.getAttribute("data-day"));
      });
    });

    // Default to the first day.
    if (tabs.length) showDay(tabs[0].getAttribute("data-day"));
  }

  /* ------------------------------------------------------------------ *
   *  9. Subtle entrance animations
   * ------------------------------------------------------------------ */
  function initAnimations() {
    var targets = $all(".recommendation-card, .category-card, .place-card, .food-card, .duration-option");
    if (!("IntersectionObserver" in window)) {
      targets.forEach(function (el) { el.classList.add("revealed"); });
      return;
    }
    var observer = new IntersectionObserver(function (entries) {
      entries.forEach(function (entry) {
        if (entry.isIntersecting) {
          entry.target.classList.add("revealed");
          observer.unobserve(entry.target);
        }
      });
    }, { threshold: 0.08 });
    targets.forEach(function (el) { observer.observe(el); });
  }

  /* ------------------------------------------------------------------ *
   *  Boot
   * ------------------------------------------------------------------ */
  document.addEventListener("DOMContentLoaded", function () {
    initBudgetSlider();
    initDurationButtons();
    initInterests();
    initSuggestions();
    initValidation();
    initFavorites();
    initFilters();
    initItinerary();
    initAnimations();
  });
})();