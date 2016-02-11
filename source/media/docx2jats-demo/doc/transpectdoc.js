update_nav = function() {
  $('p.toggle').siblings().hide();
  $('.toggle').click(function () {
    $(this).siblings().slideToggle();
    $(this).find('a').toggleClass('fold');
  });
  var page_id = $('div#transpectdoc > div.id-container').attr('id');
  var current_item = $('#nav_'+page_id+' a');
  current_item.parentsUntil('ul.nav', 'ul').each(function () {
    $(this).toggle();
  });
  current_item.parentsUntil('ul.nav', 'li').each(function () {
    $(this).find('> p a').toggleClass('fold');
  });
  current_item.toggleClass('current');
};

$(document).ready(update_nav);
