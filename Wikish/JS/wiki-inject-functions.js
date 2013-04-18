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
     if (id_span.length != 0 && id_span.parents('.openSection').length == 0) {
         hob = id_span.parents('.section_heading');
         if (hob.length == 0)
             hob = id_span.parents('.content_block');
         if (hob.length == 0)
             return;
         
         section_index = hob.attr('id').split('_')[1];
         mw.mobileFrontend._modules.toggle.wm_toggle_section(section_index);
     }
 }

  function scroll_to_section( section_id ) {
     expand_section_of_id( section_id );
     $(document.getElementById( section_id )).goTo();
     
     if (document.getElementById( section_id )) {
         return 'YES';
     }
     return 'NO';
 }

  function disable_toggling() {
     $('html').removeClass('togglingEnabled');
 }
  
  function enable_toggling() {
     $('html').addClass('togglingEnabled');
 }