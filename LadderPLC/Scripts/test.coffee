paper = null
window.onload = ->
    dragger = ->
        this.ox = if this.type == "ellipse" then this.attr("cx") else this.attr("x")
        this.oy = if this.type == "ellipse" then this.attr("cy") else this.attr("y")
        this.animate({ "fill-opacity": .2 } , 500)
    move = (dx, dy) ->
        att = if this.type == "ellipse" then { cx: this.ox + dx, cy: this.oy + dy } else { x: this.ox + dx, y: this.oy + dy }
        this.attr(att)

    paper = Raphael("holder", 600, 600)
    p = Raphael("toolbox", 100, 400)
    r = paper

    circle = p.rect(50, 40, 80, 80, 10)
    circle.attr fill: "#f00"
    circle.attr stroke: "#fff"
    circle.drag(move, dragger)

    connections = []
    shapes = [r.ellipse(190, 100, 30, 20)
                r.rect(290, 80, 60, 40, 10)
                r.rect(290, 180, 60, 40, 2)
                r.ellipse(450, 100, 20, 20)
    ]

    for shape in shapes
        do (shape) ->
            color = Raphael.getColor() ;
            shape.attr({ fill: color, stroke: color, "fill-opacity": 0, "stroke-width": 2, cursor: "move" } ) ;
            shape.drag(move, dragger)

    # r.setSize(600, 2600);
    # rct = showRect(r, 50, 40, 80,80,"text");
    # rct.attr ({ cursor: "move"})
    # rct.drag(gmove, gdragger)
    ladder = new Ladder()
    ladder.AddRung()

class Ladder
    rungs = []
    constructor: (@name) ->

    AddRung: (name) ->
        rg = new Rung()
        rungs = rungs.concat rg

class Rung

    gdragger = () ->
        this.group = this.getGroup() ;
        this.previousDy = 0;
    gmove = (dx, dy) ->
        tyGroup = dy - this.previousDy
        this.group.translate(0, tyGroup) ;
        currentY = this.group.getBBox().y;
        this.group.translate(0, - currentY) if currentY < 0
        this.previousDy = dy;

    constructor: (@name) ->
        rct = showRect(paper, 0, 0, 20, 80, "1") ;
        rct.attr ({ cursor: "move"} )
        rct.drag(gmove, gdragger)

showRect = (r, x, y, width, height, caption) ->
    rect = r.rect(x, y, width, height, 10)
    rect.attr ({fill: "#FFF", "fill-opacity": 0.3} )
    txt = r.text(x + width/2, y + height/2, caption) ;
    st = r.set()
    st.push(rect, txt)
    rect.setGroup(st)
    rect.caption = txt
    return rect

Raphael.el.setGroup = (group) -> this.group = group
Raphael.el.getGroup = () -> this.group
