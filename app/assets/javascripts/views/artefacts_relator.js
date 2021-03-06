$(document).ready(function() {
  "use strict";

  var $relatedArtefactsWrapper = $(".related-artefacts"),
      $relatedArtefactsTextArea = $("#artefact_related_artefact_slugs"),
      prefillRelatedArtefacts = $relatedArtefactsTextArea.data("related-artefacts");

  $relatedArtefactsWrapper
    .children("label")
    .html("Related artefacts")
    .append(' <span class="hint">(drag to reorder)</span>');

  // http://ivaynberg.github.io/select2/index.html
  $relatedArtefactsTextArea.select2({
    width: "75%",
    multiple: true,
    placeholder: "Enter first few characters of the artefact name",
    minimumInputLength: 3,
    initSelection: function(element, callback) {
      callback(prefillRelatedArtefacts);
    },
    formatSelection: function(object) {
      return $("<a>")
               .attr("href", "http://gov.uk/" + object.id)
               .addClass("js-artefact-name")
               .html(object.text)
               .wrap('<p>').parent().html();
    },
    ajax: {
      url: "/artefacts/search_relatable_items.json",
      quietMillis: 100,
      data: function (term, page) {
        return { 'title_substring': term, 'page': page };
      },
      results: function (data, page) {
        var loadMore = (page * 15) < data.total;
        return {results: data.artefacts, more: loadMore};
      }
    }
  });

  $(".js-artefact-name").click(function(e) {
    e.preventDefault();
    window.open($(this).attr("href"));
  });

  // drag and drop to change order of related artefacts
  $relatedArtefactsWrapper
    .select2("container")
    .find("ul.select2-choices")
    .sortable({
      containment: 'parent',
      start: function() { $relatedArtefactsTextArea.select2("onSortStart"); },
      update: function() { $relatedArtefactsTextArea.select2("onSortEnd"); }
    });
});
