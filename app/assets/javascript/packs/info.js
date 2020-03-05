import $ from 'jquery';

$(() => {
  $(".question").click(event => {
    $(event.currentTarget).toggleClass('disclosed').find('+ .answer')
                          .slideToggle();
  });
});
