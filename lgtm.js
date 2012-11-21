(function() {
  var LooksGoodToMe,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  LooksGoodToMe = (function() {

    function LooksGoodToMe(options) {
      if (options == null) options = {};
      this.get_ci_build_status_icon = __bind(this.get_ci_build_status_icon, this);
      this.make_a_badge = __bind(this.make_a_badge, this);
      this.count_ones = __bind(this.count_ones, this);
      this.refresh = __bind(this.refresh, this);
      this.refresh_rate = options.refresh_rate || 5 * 60000;
      this.default_plus_one_message = options.default_plus_one_message || '+1';
      this.good = options.good || 1;
      this.better = options.better || 2;
      this.best = options.best || 3;
      this.regexes = options.regexes || [/looks good to me/ig, /lgtm/ig, /\+1(\s|\z)/g];
      if (this.refresh_rate > 0) setInterval(this.refresh, this.refresh_rate);
      this.refresh();
    }

    LooksGoodToMe.prototype.refresh = function() {
      var _this = this;
      $('.lgtm_badge, .lgtm_button, .lgtm_icon').remove();
      $('.pulls-list .list-browser-item').each(function(index, listing) {
        var pull_url, title;
        console.log("LGTM: Pull request index page.");
        title = $(listing).find('h3');
        pull_url = title.find('a').prop('href');
        return $.get(pull_url, function(response) {
          title.prepend(_this.make_a_badge(_this.count_ones(response)));
          return title.append(_this.get_ci_build_status_icon(response).addClass('lgtm_icon'));
        });
      });
      return $('#discussion_bucket').each(function(index, discussion) {
        var badge, button, merge_button, message, refresh, title;
        console.log("LGTM: Pull request show page.");
        title = $(discussion).find('.discussion-topic-title');
        merge_button = $(discussion).find('.mergeable.clean .minibutton');
        if (badge = _this.make_a_badge(_this.count_ones(discussion), 'lgtm_large')) {
          badge.clone().prependTo(title);
          badge.clone().prependTo(merge_button);
        }
        message = _this.default_plus_one_message;
        refresh = _this.refresh;
        button = $("<button type='submit'>" + message + "</button>");
        button.addClass('classy primary lgtm_button');
        button.click(function() {
          $(this).closest('form').find('.write-content textarea').html("" + message);
          return setTimeout(refresh, 5000);
        });
        return button.insertBefore('.discussion-bubble .classy.primary');
      });
    };

    LooksGoodToMe.prototype.count_ones = function(string) {
      var ones,
        _this = this;
      ones = 0;
      $('.comment-body', string).each(function(index, comment) {
        var count, regex, _i, _len, _ref, _results;
        $(comment).find('.email-signature-reply').remove();
        $(comment).find('.email-quoted-reply').remove();
        _ref = _this.regexes;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          regex = _ref[_i];
          if (count = $(comment).text().match(regex)) {
            _results.push(ones += count.length);
          } else {
            _results.push(void 0);
          }
        }
        return _results;
      });
      console.log("LGTM: Found " + ones + " plus ones.");
      return ones;
    };

    LooksGoodToMe.prototype.make_a_badge = function(ones, extra_classes) {
      var badge;
      if (ones == null) ones = 0;
      if (extra_classes == null) extra_classes = '';
      badge = void 0;
      if (ones > 0) {
        badge = $('<span>');
        badge.addClass("lgtm_badge " + extra_classes);
        badge.html("+" + ones);
        if (ones >= this.good && ones < this.better) {
          badge.addClass('lgtm_good');
        } else if (ones >= this.better && ones < this.best) {
          badge.addClass('lgtm_better');
        } else if (ones >= this.best) {
          badge.addClass('lgtm_best');
        } else {
          badge.addClass('lgtm_okay');
        }
      }
      return badge;
    };

    LooksGoodToMe.prototype.get_ci_build_status_icon = function(page_content) {
      var icon_name;
      icon_name = 'status_icon';
      return $(".starting-comment img[src*=" + icon_name + "]", page_content);
    };

    return LooksGoodToMe;

  })();

  window.looks_good_to_me = new LooksGoodToMe();

}).call(this);
