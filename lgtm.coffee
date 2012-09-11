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
      /looks good to me/ig,
      /lgtm/ig,
      /\+1(\s|\z)/g
    ]

    if @refresh_rate > 0
      setInterval(@refresh, @refresh_rate)

    @refresh()

  refresh: =>
    # Remove previous badges
    $('.lgtm_badge').remove()

    # We're on a pull request index page
    $('.pulls .listing').each (index, listing) =>
      #console.log "LGTM: Pull request index page."
      title = $(listing).find('h3')
      pull_url = title.find('a').prop('href')

      # Who needs apis? :)
      # Get the pull comments, for example: https://github.com/nikolaiwarner/Looks-Good-To-Me/pull/21
      $.get pull_url, (response) =>
        title.prepend(@make_a_badge(@count_ones(response)))

    # We're on a pull request show page
    $('#discussion_bucket').each (index, discussion) =>
      console.log "LGTM: Pull request show page."
      title = $(discussion).find('.discussion-topic-title')
      merge_button = $(discussion).find('.mergeable.clean .minibutton')

      if badge = @make_a_badge(@count_ones(discussion), 'lgtm_large')
        badge.clone().prependTo(title)
        badge.clone().prependTo(merge_button)

      # Show Plus One, the button
      message = @default_plus_one_message
      refresh = @refresh
      button = $("<button type='submit'>#{message}</button>")
      button.addClass('classy primary')
      button.click ->
        $(@).closest('form').find('.write-content textarea').html("#{message}")
        setTimeout(refresh, 5000)
      button.insertBefore('.discussion-bubble .classy.primary')


  # Count plus ones in each comment
  count_ones: (string) =>
    ones = 0
    # Scrape out and count what we want from the string
    $('.comment-body', string).each (index, comment) =>
      # Clean up the comment body
      $(comment).find('.email-signature-reply').remove()
      $(comment).find('.email-quoted-reply').remove()

      for regex in @regexes
        if count = $(comment).text().match(regex)
          ones += count.length

    #console.log "LGTM: Found #{ones} plus ones."
    return ones


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


window.looks_good_to_me = new LooksGoodToMe()
