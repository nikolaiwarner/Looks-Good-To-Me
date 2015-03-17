# Looks Good To Me
# by Nikolai Warner, 2012

class LooksGoodToMe
  constructor: (options={}) ->
    @refresh_rate = options.refresh_rate || 5 * 60000
    @default_plus_one_message = options.default_plus_one_message || '+1'

    @good = options.good || 1
    @better = options.better || 2
    @best = options.best || 3

    @regexes = options.regexes || [
      /looks good to me/ig
      /lgtm/ig
      /(\s|\z|>)?\+1(\s|\z|<)?/g
      /title=":\+1:"/ig
      /title=":thumbsup:"/ig
    ]

    @restore_options()

    # Initialize Chrome Events
    #document.addEventListener "DOMContentLoaded", =>
    #  if $("body.lgtm.options").length > 0 # Init for Options Page
    #    $(".save_button").click => @save_options()
    #    console.log "Options Page."

    # Init for Github pages
    if @refresh_rate > 0
      setInterval(@refresh, @refresh_rate)
    @refresh()

  refresh: =>
    # Remove previous badges
    $('.lgtm_badge, .lgtm_button, .lgtm_icon, .lgtm_container').remove()

    # We're on a pull request index page
    $('.pulls-list-group .list-group-item').each (index, listing) =>
      title = $(listing).find('h4')
      pull_url = title.find('a').prop('href')
      authorInfo = $(listing).find('.list-group-item-meta li').first()
      author_name = authorInfo.find('a').not('.gravatar').text()

      # Who needs apis? :)
      # Get the pull comments, for example:
      # https://github.com/nikolaiwarner/Looks-Good-To-Me/pull/21
      $.get pull_url, (response) =>
        container = $('<div>')
        container.addClass('lgtm_container')
        title.before(container)

        ones_count = @count_ones(response, author_name)
        container.append(@make_a_badge(ones_count.ones))
        container.find('.lgtm_badge').append(@list_participants(ones_count.participants))

    # We're on a pull request show page
    $('.view-pull-request').each (index, pullrequest) =>
      title = $(pullrequest).find('.gh-header-title')
      merge_button = $(pullrequest).find('.merge-branch-action').first()
      author_name = $(pullrequest).find('.gh-header-meta .author').text()

      ones_count = @count_ones(pullrequest, author_name)
      if badge = @make_a_badge(ones_count.ones, 'lgtm_large')
        badge.clone().prependTo(title)
        badge.clone().prependTo(merge_button)
        merge_button.find('.lgtm_large').append(@list_participants(ones_count.participants))

      # Show Plus One, the button
      message = @default_plus_one_message
      refresh = @refresh
      button = $("<button type='submit'>#{message}</button>")
      button.addClass('button primary lgtm_button')
      button.click ->
        $(@).closest('form').find('.write-content textarea').html("#{message}")
        setTimeout(refresh, 5000)
      button.insertBefore('.timeline-new-comment .button.primary')

  # Count plus ones in each comment
  count_ones: (string, author_name) =>
    ones = 0
    participants = {}

    # Scrape out and count what we want from the string
    $('.timeline-comment-wrapper', string).each (index, comment) =>
      # Clean up the comment body
      $(comment).find('.email-signature-reply').remove()
      $(comment).find('.email-quoted-reply').remove()

      # Capture information about particitpant
      timeline_comment = $(comment).find('.comment-body p').html()
      participant_name = $(comment).find('.timeline-comment-header-text .author').text()
      participant_image = $(comment).find('.timeline-comment-avatar').clone()

      # You can't upvote your own pull request or vote twice
      #if participants[participant_name] or participant_name == author_name
      #  return
      for regex in @regexes
        console.log regex, timeline_comment.match(regex), timeline_comment
        if timeline_comment.match(regex)
          ones += 1
          # Save name and image of participant
          participants[participant_name] = participant_image
          break

    return {
      ones: ones
      participants: participants
    }

  make_a_badge: (ones=0, extra_classes='') =>
    badge = undefined
    if ones > 0
      badge = $('<span>')
      badge.addClass("lgtm_badge #{extra_classes}")
      badge.html("+#{ones}")

      # Set the color based on momentum
      if ones >= @good and ones < @better
        badge.addClass('lgtm_good')
      else if ones >= @better and ones < @best
        badge.addClass('lgtm_better')
      else if ones >= @best
        badge.addClass('lgtm_best')
      else
        badge.addClass('lgtm_okay')
    return badge

  list_participants: (participants={}) =>
    list = $('<span>')
    list.addClass('lgtm_participants')
    for name, image of participants
      image.prop('title', name)
      image.addClass('participant_thumb')
      list.append(image)
    return list

  restore_options: =>
    chrome.storage.sync.get null, (items) =>
      $("#regexes").attr("checked", (items["show_badge"] == "true"))
      $("#refresh_rate").attr("checked", (items["show_notification"] == "true"))
      $("#default_plus_one_message").val(items["rss_url"])

    # Listen for storage changes
    chrome.storage.onChanged.addListener (changes, namespace) ->
      for key in changes
        storageChange = changes[key]
        @[key] = storageChange.newValue
        console.log('Storage key "%s" in namespace "%s" changed. Old value was "%s", new value is "%s".', key, namespace, storageChange.oldValue, storageChange.newValue)

  save_options: =>
    chrome.storage.sync.set()
      'regexes': $('#regexes').val()
      'refresh_rate': $('#refresh_rate').val()
      'default_plus_one_message': $('#default_plus_one_message').val()
      , => message('Settings saved.')

window.looks_good_to_me = new LooksGoodToMe()
