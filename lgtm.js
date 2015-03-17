// Generated by CoffeeScript 1.6.3
(function() {
  var LooksGoodToMe,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  LooksGoodToMe = (function() {
    function LooksGoodToMe(options) {
      if (options == null) {
        options = {};
      }
      this.save_options = __bind(this.save_options, this);
      this.restore_options = __bind(this.restore_options, this);
      this.list_participants = __bind(this.list_participants, this);
      this.make_a_badge = __bind(this.make_a_badge, this);
      this.count_ones = __bind(this.count_ones, this);
      this.refresh = __bind(this.refresh, this);
      this.refresh_rate = options.refresh_rate || 5 * 60000;
      this.default_plus_one_message = options.default_plus_one_message || '+1';
      this.good = options.good || 1;
      this.better = options.better || 2;
      this.best = options.best || 3;
      this.regexes = options.regexes || [/looks good to me/ig, /lgtm/ig, /(\s|\z|>)?\+1(\s|\z|<)?/g, /title=":\+1:"/ig, /title=":thumbsup:"/ig];
      this.restore_options();
      if (this.refresh_rate > 0) {
        setInterval(this.refresh, this.refresh_rate);
      }
      this.refresh();
    }

    LooksGoodToMe.prototype.refresh = function() {
      var _this = this;
      $('.lgtm_badge, .lgtm_button, .lgtm_icon, .lgtm_container').remove();
      $('.pulls-list-group .list-group-item').each(function(index, listing) {
        var authorInfo, author_name, pull_url, title;
        title = $(listing).find('h4');
        pull_url = title.find('a').prop('href');
        authorInfo = $(listing).find('.list-group-item-meta li').first();
        author_name = authorInfo.find('a').not('.gravatar').text();
        return $.get(pull_url, function(response) {
          var container, ones_count;
          container = $('<div>');
          container.addClass('lgtm_container');
          title.before(container);
          ones_count = _this.count_ones(response, author_name);
          container.append(_this.make_a_badge(ones_count.ones));
          return container.find('.lgtm_badge').append(_this.list_participants(ones_count.participants));
        });
      });
      return $('.view-pull-request').each(function(index, pullrequest) {
        var author_name, badge, button, merge_button, message, ones_count, refresh, title;
        title = $(pullrequest).find('.gh-header-title');
        merge_button = $(pullrequest).find('.merge-branch-action').first();
        author_name = $(pullrequest).find('.gh-header-meta .author').text();
        ones_count = _this.count_ones(pullrequest, author_name);
        if (badge = _this.make_a_badge(ones_count.ones, 'lgtm_large')) {
          badge.clone().prependTo(title);
          badge.clone().prependTo(merge_button);
          merge_button.find('.lgtm_large').append(_this.list_participants(ones_count.participants));
        }
        message = _this.default_plus_one_message;
        refresh = _this.refresh;
        button = $("<button type='submit'>" + message + "</button>");
        button.addClass('button primary lgtm_button');
        button.click(function() {
          $(this).closest('form').find('.write-content textarea').html("" + message);
          return setTimeout(refresh, 5000);
        });
        return button.insertBefore('.timeline-new-comment .button.primary');
      });
    };

    LooksGoodToMe.prototype.count_ones = function(string, author_name) {
      var ones, participants,
        _this = this;
      ones = 0;
      participants = {};
      $('.timeline-comment-wrapper', string).each(function(index, comment) {
        var participant_image, participant_name, regex, timeline_comment, _i, _len, _ref, _results;
        $(comment).find('.email-signature-reply').remove();
        $(comment).find('.email-quoted-reply').remove();
        timeline_comment = $(comment).find('.comment-body p').html();
        participant_name = $(comment).find('.timeline-comment-header-text .author').text();
        participant_image = $(comment).find('.timeline-comment-avatar').clone();
        _ref = _this.regexes;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          regex = _ref[_i];
          console.log(regex, timeline_comment.match(regex), timeline_comment);
          if (timeline_comment.match(regex)) {
            ones += 1;
            participants[participant_name] = participant_image;
            break;
          } else {
            _results.push(void 0);
          }
        }
        return _results;
      });
      return {
        ones: ones,
        participants: participants
      };
    };

    LooksGoodToMe.prototype.make_a_badge = function(ones, extra_classes) {
      var badge;
      if (ones == null) {
        ones = 0;
      }
      if (extra_classes == null) {
        extra_classes = '';
      }
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

    LooksGoodToMe.prototype.list_participants = function(participants) {
      var image, list, name;
      if (participants == null) {
        participants = {};
      }
      list = $('<span>');
      list.addClass('lgtm_participants');
      for (name in participants) {
        image = participants[name];
        image.prop('title', name);
        image.addClass('participant_thumb');
        list.append(image);
      }
      return list;
    };

    LooksGoodToMe.prototype.restore_options = function() {
      var _this = this;
      chrome.storage.sync.get(null, function(items) {
        $("#regexes").attr("checked", items["show_badge"] === "true");
        $("#refresh_rate").attr("checked", items["show_notification"] === "true");
        return $("#default_plus_one_message").val(items["rss_url"]);
      });
      return chrome.storage.onChanged.addListener(function(changes, namespace) {
        var key, storageChange, _i, _len, _results;
        _results = [];
        for (_i = 0, _len = changes.length; _i < _len; _i++) {
          key = changes[_i];
          storageChange = changes[key];
          this[key] = storageChange.newValue;
          _results.push(console.log('Storage key "%s" in namespace "%s" changed. Old value was "%s", new value is "%s".', key, namespace, storageChange.oldValue, storageChange.newValue));
        }
        return _results;
      });
    };

    LooksGoodToMe.prototype.save_options = function() {
      var _this = this;
      return chrome.storage.sync.set()({
        'regexes': $('#regexes').val(),
        'refresh_rate': $('#refresh_rate').val(),
        'default_plus_one_message': $('#default_plus_one_message').val()
      }, function() {
        return message('Settings saved.');
      });
    };

    return LooksGoodToMe;

  })();

  window.looks_good_to_me = new LooksGoodToMe();

}).call(this);
