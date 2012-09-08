refresh_time = 5 * 60000

good = 1
better = 2
best = 3

lgtm_regexes = [
  /looks good to me/ig,
  /lgtm/ig,
  /\+1/g
]


window.lgtm_refresh = ->

  $('.pulls .listing').each (index, listing) =>
    ones = 0
    title = $(listing).find('h3')
    pull_url = title.find('a').prop('href')

    # Remove previous badges
    title.find('.lgtm_badge').remove()

    # Get the pull id, for example: https://github.com/nikolaiwarner/Looks-Good-To-Me/pull/21
    id = pull_url.split('/pull/')[1]

    # Who needs apis? :)
    # Get the pull comments, for example: https://github.com/nikolaiwarner/Looks-Good-To-Me/pull/21
    $.get pull_url, (response) =>

      # Count plus ones in each comment
      $('.comment-body', response).each (i, comment) =>
        for regex in lgtm_regexes
          if count = $(comment).text().match(regex)
            ones += count.length

      if ones > 0
        # Update title with lgtm count
        badge = $('<span>')
        badge.addClass('lgtm_badge')
        badge.html("[+#{ones}]")

        # Set the color based on strength
        if ones >= good and ones < best
          badge.addClass('lgtm_better')
        else if ones >= best
          badge.addClass('lgtm_best')
        else
          badge.addClass('lgtm_good')

        title.prepend(badge)


window.lgtm_refresh()
setInterval(window.lgtm_refresh, refresh_time)
