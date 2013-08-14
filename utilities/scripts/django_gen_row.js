(function () {

  if ( !window.jQuery ) {
    var s = document.createElement('script');
    s.setAttribute('src', '//ajax.googleapis.com/ajax/libs/jquery/2.0.3/jquery.min.js');
    document.body.appendChild(s);
    console.log('jquery loaded!');
  }

})();
(function($){
    $('.inline-group').each(function() {
        var $group = $(this);
        var $tpl_obj = $group.find('.inline-related').first();
        var $new_obj;
        var cur_index = $group.find('.inline-related').length;

        // track the last index to be used on new objects
        $group.data('last-index', cur_index);

        $group.find('.add-row a').on('click', function() {

           $new_obj = $group.find('.inline-related:not(.empty-form)').last();

           // input fields
           $new_obj.find('input[type=text], textarea').each(function() {
               var $tgt_field = $(this);
               var $src_field = $tpl_obj.find('#'+$tgt_field.attr('id').replace(/\d+/,0));
               $tgt_field.val($src_field.val().replace(/\d+/,cur_index));
           })

           // checkboxes
           $new_obj.find('input[type=checkbox]').each(function() {
               var $tgt_field = $(this);
               var $src_field = $tpl_obj.find('#'+$tgt_field.attr('id').replace(/\d+/,0));
               if ($src_field.attr('checked')) {
                   $tgt_field.attr('checked', $src_field.attr('checked'));
               }
               else {
                   $tgt_field.removeAttr('checked');
               }
           })

           // select dropdowns
           $new_obj.find('select').each(function() {
               var $tgt_field = $(this);
               var $src_field = $tpl_obj.find('#'+$tgt_field.attr('id').replace(/\d+/,0));
               console.log($src_field);
               var $tgt_option = $tgt_field.find('option[value='+$src_field.val()+']');
               if ($tgt_option.length) {
                 $tgt_option.first().attr('selected','selected');
               }
           })

           // TODO: radio buttons

           // TODO: file input fields (this won't work for security reasons)
           // $new_obj.find('input[type=file]').each(function() {
           //     var $tgt_field = $(this);
           //     var $src_field = $tpl_obj.find('#'+$tgt_field.attr('id').replace(/\d+/,0));

           //     // we can't read the value of a file field for security reasons, so we clone it
           //     var $clone = $src_field.clone();
           //     $clone.attr({
           //       id: $tgt_field.attr('id'),
           //       name: $tgt_field.attr('name')
           //     });
           //     $tgt_field.replaceWith($clone);
           // })
           $new_obj.find('input[type=file]').first().focus();

           cur_index++;
           $group.data('last-index', cur_index);
        });
    })
})(jQuery);
