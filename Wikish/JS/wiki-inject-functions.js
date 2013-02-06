(function($) {
    $.fn.goTo = function() {
        $('html, body').animate({
            scrollTop: $(this).offset().top + 'px'
        }, 'fast');
        return this; // for chaining...
    }
})(jQuery);

function expand_section_of_id( section_id ) {
  id_span = $(document.getElementById(section_id));
  // Parent has openSection class means it is visible
  if (id_span.length != 0 && id_span.parents('.openSection').length == 0) {
    // hob is short for heading or block
    hob = id_span.parents('.section_heading');
    if (hob.length == 0)
      hob = id_span.parents('.content_block');
    if (hob.length == 0) 
      return;

    section_index = hob.attr('id').split('_')[1];
    mw.mobileFrontend.getModule('toggle').wm_toggle_section(section_index);
  }
}

function toggle_all_section( expand ) {
  section_cnt = $('#content').children('.section').length - 3;
  toggle_cnt = 0;
  for (var i=1; i<=section_cnt; ++i) {
    section_selector = '#section_' + i;
    if ($(section_selector).hasClass('openSection') != expand) {
      toggle_cnt = toggle_cnt + 1;
      mw.mobileFrontend.getModule('toggle').wm_toggle_section(i);
    }
  }
  return '' + toggle_cnt;
}

function scroll_to_section( section_id ) {
  expand_section_of_id( section_id );
  $(document.getElementById( section_id )).goTo();
}

function section_not_expand_cnt() {
  section_cnt = $('#content').children('.section').length;
  cnt = 0;
  for (var i=1; i<=section_cnt; ++i) {
    section_selector = '#section_' + i;
    if ($(section_selector).hasClass('openSection') == false)
      cnt = cnt + 1;
  }
  return ''+ cnt;
}

function get_section_cnt() {
  cnt = $('#content').children('.section').length;
  return '' + cnt;
}