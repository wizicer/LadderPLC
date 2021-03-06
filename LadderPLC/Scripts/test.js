// Generated by CoffeeScript 1.7.1
var Ladder, Rung, paper, showRect;

paper = null;

window.onload = function() {
  var circle, connections, dragger, ladder, move, p, r, shape, shapes, _fn, _i, _len;
  dragger = function() {
    this.ox = this.type === "ellipse" ? this.attr("cx") : this.attr("x");
    this.oy = this.type === "ellipse" ? this.attr("cy") : this.attr("y");
    return this.animate({
      "fill-opacity": .2
    }, 500);
  };
  move = function(dx, dy) {
    var att;
    att = this.type === "ellipse" ? {
      cx: this.ox + dx,
      cy: this.oy + dy
    } : {
      x: this.ox + dx,
      y: this.oy + dy
    };
    return this.attr(att);
  };
  paper = Raphael("holder", 600, 600);
  p = Raphael("toolbox", 100, 400);
  r = paper;
  circle = p.rect(50, 40, 80, 80, 10);
  circle.attr({
    fill: "#f00"
  });
  circle.attr({
    stroke: "#fff"
  });
  circle.drag(move, dragger);
  connections = [];
  shapes = [r.ellipse(190, 100, 30, 20), r.rect(290, 80, 60, 40, 10), r.rect(290, 180, 60, 40, 2), r.ellipse(450, 100, 20, 20)];
  _fn = function(shape) {
    var color;
    color = Raphael.getColor();
    shape.attr({
      fill: color,
      stroke: color,
      "fill-opacity": 0,
      "stroke-width": 2,
      cursor: "move"
    });
    return shape.drag(move, dragger);
  };
  for (_i = 0, _len = shapes.length; _i < _len; _i++) {
    shape = shapes[_i];
    _fn(shape);
  }
  ladder = new Ladder();
  return ladder.AddRung();
};

Ladder = (function() {
  var rungs;

  rungs = [];

  function Ladder(name) {
    this.name = name;
  }

  Ladder.prototype.AddRung = function(name) {
    var rg;
    rg = new Rung();
    return rungs = rungs.concat(rg);
  };

  return Ladder;

})();

Rung = (function() {
  var gdragger, gmove;

  gdragger = function() {
    this.group = this.getGroup();
    return this.previousDy = 0;
  };

  gmove = function(dx, dy) {
    var currentY, tyGroup;
    tyGroup = dy - this.previousDy;
    this.group.translate(0, tyGroup);
    currentY = this.group.getBBox().y;
    if (currentY < 0) {
      this.group.translate(0, -currentY);
    }
    return this.previousDy = dy;
  };

  function Rung(name) {
    var rct;
    this.name = name;
    rct = showRect(paper, 0, 0, 20, 80, "1");
    rct.attr({
      cursor: "move"
    });
    rct.drag(gmove, gdragger);
  }

  return Rung;

})();

showRect = function(r, x, y, width, height, caption) {
  var rect, st, txt;
  rect = r.rect(x, y, width, height, 10);
  rect.attr({
    fill: "#FFF",
    "fill-opacity": 0.3
  });
  txt = r.text(x + width / 2, y + height / 2, caption);
  st = r.set();
  st.push(rect, txt);
  rect.setGroup(st);
  rect.caption = txt;
  return rect;
};

Raphael.el.setGroup = function(group) {
  return this.group = group;
};

Raphael.el.getGroup = function() {
  return this.group;
};
