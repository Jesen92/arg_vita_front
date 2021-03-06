(function() {
  $(function() {
    var categories, material, options;
    categories = $('#filterrific_with_ssubcategory_id').html();
    material = $('#filterrific_with_subcategory_id :selected').text();
    if (material === "- Sve -") {
      $('#filterrific_with_ssubcategory_id').empty();
      $('#filterrific_with_ssubcategory_id').trigger("chosen:updated");
    } else {
      options = $(categories).filter("optgroup[label='" + material + "']").prepend($("<option></option>").attr("value", 9999).text("- Sve -")).html();
      $('#filterrific_with_ssubcategory_id').html(options);
      $('#filterrific_with_ssubcategory_id').trigger("chosen:updated");
    }
    return $('#filterrific_with_subcategory_id').change(function() {
      material = $('#filterrific_with_subcategory_id :selected').text();
      options = $(categories).filter("optgroup[label='" + material + "']").prepend($("<option></option>").attr("value", 9999).text("- Sve -"));
      if (options) {
        $('#filterrific_with_ssubcategory_id').html(options);
        $('#filterrific_with_ssubcategory_id').trigger("chosen:updated");
        return $('#filterrific_with_ssubcategory_id').parent().show();
      } else {
        return $('#filterrific_with_ssubcategory_id').trigger("chosen:updated").empty();
      }
    });
  });

}).call(this);
