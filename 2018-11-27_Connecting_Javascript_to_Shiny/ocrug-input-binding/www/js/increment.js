// Event handler is installed on all instances of the input
$(document).on("click", "button.increment", evt => {
  const el = $(evt.target);
  el.text(parseInt(el.text()) + 1);
  el.trigger("change");
});

// Shiny machinery calls these functions in response to change event
// triggered above.
class IncrementBinding extends Shiny.InputBinding {
  find(scope) {
    return $(scope).find(".increment");
  }
  getValue(el) {
    return parseInt($(el).text());
  }
  setValue(el, value) {
    $(el).text(value)
  }
  subscribe(el, callback) {
    $(el).on("change.incrementBinding", function(e) {
      callback();
    });
  }
  unsubscribe(el) {
    $(el).off(".incrementBinding")
  }
}

Shiny.inputBindings.register(new IncrementBinding());