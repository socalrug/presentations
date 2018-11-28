function blinkify($el) {
  if (!$el.data('blinking')) {
    $el.data('blinking', true);
    setInterval(() => {
      $el.toggle();
    }, parseInt($el.data('interval')))
  }
}

class BlinkBinding extends Shiny.OutputBinding {
  find(scope) {
    return $(scope).find(".blink");
  }
  renderValue(el, data) {
    blinkify($(el));
    $(el).text(data)
  }
}

Shiny.outputBindings.register(new BlinkBinding());