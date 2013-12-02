// Keyboard shortcuts for browsing pages of lists
(function($) {
    $(document).keydown(handleKey);
    function handleKey(e) {
        var left_arrow = 37;
        var right_arrow = 39;
        if (e.target.nodeName == 'BODY' || e.target.nodeName == 'HTML') {
            if (!e.ctrlKey && !e.altKey && !e.shiftKey && !e.metaKey) {
                var code = e.which;
                if (code == left_arrow) {
                    var prev_link = $('.pagination li.prev a');
                    var href = prev_link.attr('href');
                    if (href != undefined && href != "#") {
                        location.href = href;
                    }
                }
                else if (code == right_arrow) {
                    var next_link = $('.pagination li.next a')
                    var href = next_link.attr('href');
                    if (href != undefined && href != "#") {
                        location.href = href;
                    }
                }
            }
        }
    }
})(jQuery);
