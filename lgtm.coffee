# Looks Good To Me
# by Nikolai Warner, 2012

class LooksGoodToMe
  constructor: (options={}) ->
    @refresh_rate = options.refresh_rate || 5 * 60000

    @ci_status_selector = options.ci_status_selector || 'status_icon'

    @default_plus_one_message = options.default_plus_one_message || '+1'

    @good = options.good || 1
    @better = options.better || 2
    @best = options.best || 3

    @regexes = options.regexes || [
      /looks good to me/ig,
      /lgtm/ig,
      /(\s|\z|>)\+1(\s|\z|<)/g,
      /title=":\+1:"/ig
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
    $('.pulls-list .list-browser-item').each (index, listing) =>
      title = $(listing).find('h3')
      pull_url = title.find('a').prop('href')

      # Who needs apis? :)
      # Get the pull comments, for example:
      # https://github.com/nikolaiwarner/Looks-Good-To-Me/pull/21
      $.get pull_url, (response) =>
        container = $('<div>')
        container.addClass('lgtm_container')
        title.before(container)

        ones_count = @count_ones(response)
        container.append(@make_a_badge(ones_count.ones))
        container.find('.lgtm_badge').append(@list_participants(ones_count.participants))
        #container.append(@get_ci_build_status_icon(response).addClass('lgtm_icon'))


    # We're on a pull request show page
    $('#discussion_bucket').each (index, discussion) =>
      title = $(discussion).find('.discussion-topic-title')
      merge_button = $(discussion).find('.mergeable .minibutton').first()

      ones_count = @count_ones(discussion)
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
      button.insertBefore('.discussion-bubble .button.primary')


  # Count plus ones in each comment
  count_ones: (string) =>
    ones = 0
    participants = []
    # Scrape out and count what we want from the string
    $('.comment-body', string).each (index, comment) =>
      # Clean up the comment body
      $(comment).find('.email-signature-reply').remove()
      $(comment).find('.email-quoted-reply').remove()

      for regex in @regexes
        if count = $(comment).html().match(regex)
          ones += 1

          # Capture information about particitpant
          comment_bubble = $(comment).closest('.discussion-bubble')
          participants.push
            name: $(comment_bubble).find('.comment-header-author').text()
            image: $(comment_bubble).find('.discussion-bubble-avatar')
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


  list_participants: (participants=[]) =>
    list = $('<span>')
    list.addClass('lgtm_participants')
    for participant in participants
      image = participant.image
      image.prop('title', participant.name)
      image.addClass('participant_thumb')
      list.append(image)
    return list


  restore_options: =>
    chrome.storage.sync.get null, (items) =>
      $("#regexes").attr("checked", (items["show_badge"] == "true"))
      $("#refresh_rate").attr("checked", (items["show_notification"] == "true"))
      $("#ci_status_selector").val(items["rss_url"])
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
      'ci_status_selector': $('#ci_status_selector').val()
      'default_plus_one_message': $('#default_plus_one_message').val()
      , => message('Settings saved.')


  # Some projects use a CI system which output the build status into Github
  # pull request messages. If this is included, show on index pages.
  get_ci_build_status_icon: (page_content) =>
    $(".starting-comment img[src*=#{@ci_status_selector}]", page_content)


window.looks_good_to_me = new LooksGoodToMe()
