$(function() {
        $.ajax({
            url: '/commissionnode',
            type: 'GET',
            success: function(res) {
 
                // Parse the JSON response
                var wishObj = JSON.parse(res);
                 
                // Append to the template
                $('#listTemplate').tmpl(wishObj).appendTo('#ulist');
 
 
            },
            error: function(error) {
                console.log(error);
            }
        });
    });

