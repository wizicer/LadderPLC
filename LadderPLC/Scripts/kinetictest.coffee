window.onload = ->
    stage = new Kinetic.Stage(
      container: "holder"
      width: 578
      height: 400
    )
    DrawToolbox(stage)

    drawLayer = new Kinetic.Layer(
        x: 60
    )
    zoom = (e) ->
        if e.altKey
            zoomAmount = drawLayer.getScale().x+e.wheelDeltaY*0.001
            drawLayer.scale(x: zoomAmount, y: zoomAmount)
            drawLayer.draw()

    document.addEventListener("mousewheel", zoom, false)

    stage.add drawLayer
    ld = InitialData(drawLayer)
    console.log JSON.stringify(ld)

InitialData = (drawLayer) ->
    ladder = new Ladder(drawLayer)
    rg = ladder.AddRung()
    rg.AddElement("Relay", "AI0")
    rg.AddElement("Relay", "AI1")
    rg.AddElement("Relay", "AI2")
    rg.AddElement("Coil", "AO1")
    rg.AddElement("Relay", "AI2")
    rg = ladder.AddRung()
    rg.AddElement("Relay", "AI01")
    rg.AddElement("Relay", "AI11")
    rg.AddElement("Coil", "AO1")
    rg.AddElement("Relay", "AI21")  
    rg = ladder.AddRung()
    rg.AddElement("Relay", "AI02")
    rg.AddElement("Coil", "AO2")
    rg.AddElement("Relay", "AI12")
    rg.AddElement("Relay", "AI22")
    drawLayer.draw()
    ladder

class Ladder
    constructor: (layer) ->
        this.rungs = []
        this.parentlayer = layer
        this.layer = new Kinetic.Group()
        this.parentlayer.add this.layer
        this.posindicator = new Kinetic.Line(points: [0, 0, Rung.getheadwidth() + 5, 0], stroke: 'brown', strokeWidth: 2)
        this.layer.add this.posindicator
        this.posindicator.hide()
    AddRung: (name) ->
        num = this.rungs.length
        rg = new Rung(this, num)
        this.posindicator.moveToTop()
        sum = 0
        sum += r.getHeight() for r in this.rungs
        rg.setOffset sum
        this.rungs = this.rungs.concat rg
        rg

    MoveIndicator: (offset) ->
        this.posindicator.show()
        rightpos = 0
        i = 0
        while i < this.rungs.length
            leftpos = rightpos
            rightpos += this.rungs[i].getHeight()
            if rightpos > offset >= leftpos
                i = i+1 if offset - leftpos > rightpos - offset
                rightpos = if offset - leftpos > rightpos - offset then rightpos else leftpos
                break
            i++
            # i = this.rungs.length if offset > rightpos and i == this.rungs.length - 1
        this.posindicator.setAttr('y', rightpos)# - this.rungs[i].getHeight())
        i
        # [..., pos] = while pos < offset-20 and i < this.rungs.length - 1
        #     i++
        #     pos += this.rungs[i].getHeight()
        # this.posindicator.setAttr('y', pos)# - this.rungs[i].getHeight())

    HideIndicator: -> 
        this.posindicator.hide()

    ReorderRung: (from, to)->
        this.rungs.splice(to, 0, this.rungs.splice(from, 1)[0])
        i = 0
        pos = 0
        while i < this.rungs.length
            rg = this.rungs[i]
            rg.setOffset pos
            rg.setNumber i
            pos += rg.getHeight()
            i++

class Rung
    height = 100
    headwidth = 20
    this.getheadwidth = -> headwidth

    constructor: (parent, number) ->
        this.elements = []
        this.ladder = parent
        this.parentlayer = parent.layer
        this.layer = new Kinetic.Group(dragBoundFunc: (pos) -> {x: this.getAbsolutePosition().x, y: pos.y})
        this.parentlayer.add this.layer
        this.layer.target = this

        this.head = new Kinetic.Group()
        headrect = new Kinetic.Rect(x: 0, y: 0, width: headwidth, height: height, fill: "#fff")
        this.head.add headrect
        this.layer.add this.head

        this.number = number
        this.numbertext = new Kinetic.Text(x: 0, y: 0, width: headwidth, height: height, text: this.number, align: 'center', fontSize: 18, fill: 'blue')
        this.head.add this.numbertext

        this.track = new Kinetic.Line(points: [headwidth + 5, 0, headwidth + 5, height], stroke: 'black', strokeWidth: 2)
        this.layer.add this.track
        this.head.parentlayer = this.layer
        this.head.on "mouseover", ->
          document.body.style.cursor = "move"
          this.parentlayer.draggable true

        this.head.on "mouseout", ->
          document.body.style.cursor = "default"
          this.parentlayer.draggable false

        this.layer.on "dragstart", (evt)->
            this.opacity(0.5)
            this.draw()

        this.layer.on "dragend", (evt)->
            this.setAttr('y', this.target.offset)
            this.opacity(1)
            num = this.target.ladder.MoveIndicator(evt.layerY)
            this.target.ladder.ReorderRung(this.target.number, num)
            this.target.ladder.HideIndicator()
            this.parent.parent.draw()
            # console.log 'dragend'

        this.layer.on "dragmove", (evt) ->
            this.target.ladder.MoveIndicator(evt.layerY)
            # console.log 'dragmove'



    getHeight: -> height

    setOffset: (offset) ->
        this.layer.setAttr('y', offset)
        this.offset = offset;

    AddElement: (type, name) ->
        ele = switch type
            when "Relay" then new Relay(this.layer, name)
            when "Coil" then new Coil(this.layer, name)
            else undefined

        [..., lastelement] = this.elements
        left = if lastelement == undefined then headwidth + 5 else lastelement.getWidth()
        ele.moveto left, 25, height / 2 - ele.getHeight() / 2
        ele.render()
        this.elements = this.elements.concat ele
        ele

    setNumber: (number) ->
        this.numbertext.setAttr('text', number)
        this.number = number
            
        

class Element
    constructor: (layer) ->
        this.parentlayer = layer
        this.layer = new Kinetic.Group()
        this.parentlayer.add this.layer

    getWidth: -> 0

    getHeight: -> 0

    render: ->

    moveto: (xbase, x, y) -> 
        this.left = xbase + x
        this.layer.setAttr('x', xbase + x)
        this.layer.setAttr('y', y)
        this.fronttrack.setAttr('points', [-x, this.getHeight() / 2, 0, this.getHeight() / 2])

class Relay extends Element
    height = 25
    interval = 20
    color = "black"
    stroke = 2    

    constructor: (layer, name) ->
        super layer
        name = "" if name == undefined
        this.lefttrack = new Kinetic.Line(points: [0, 0, 0, height], stroke: color, strokeWidth: stroke)
        this.righttrack = new Kinetic.Line(points: [interval, 0, interval, height], stroke: color, strokeWidth: stroke)
        this.fronttrack = new Kinetic.Line(points: [0, 0, 0, 0], stroke: color, strokeWidth: stroke)
        this.caption = new Kinetic.Text(x: - interval / 2, y: -20, width: 40, align: 'center', text: name, fill: 'red', fontSize: 12)

        this.layer.add this.lefttrack
        this.layer.add this.righttrack
        this.layer.add this.fronttrack
        this.layer.add this.caption

    getWidth: -> this.left + interval #+ 2 * stroke

    render: -> 

    getHeight: -> height

class Coil extends Element
    rad = 12
    color = "black"
    stroke = 2    

    constructor: (layer, name) ->
        super layer
        name = "" if name == undefined
        this.coil = new Kinetic.Circle(x: rad, y: rad, radius: rad, stroke: color, strokeWidth: stroke)
        this.fronttrack = new Kinetic.Line(points: [0, 0, 0, 0], stroke: color, strokeWidth: stroke)
        this.caption = new Kinetic.Text(x: - rad, y: -20, width: 40, align: 'center', text: name, fill: 'red', fontSize: 12)

        this.layer.add this.coil
        this.layer.add this.fronttrack
        this.layer.add this.caption

    getWidth: -> this.left + 2 * rad

    render: -> 

    getHeight: -> 2 * rad

DrawToolbox = (stage) ->

    shapesLayer = new Kinetic.Layer()
    group = new Kinetic.Group()
    colors = [
      "red"
      "orange"
      "yellow"
      "green"
      "blue"
      "purple"
    ]
    n = 0

    while n < 6

      # anonymous function to induce scope
      (->
        i = n
        box = new Kinetic.Rect(
          x: 10
          y: i * 50 + 10
          width: 40
          height: 40
          name: colors[i]
          fill: colors[i]
          stroke: "white"
          strokeWidth: 3
          draggable: true
        )
        box.ox = box.x();
        box.oy = box.y();
        group.add box
        return
      )()
      n++
    group.on "mouseover", ->
      document.body.style.cursor = "pointer"

    group.on "mouseout", ->
      document.body.style.cursor = "default"

    group.on "dragstart", (evt)->
        # node = evt.targetNode
        # node.ox = node.x()
        # node.oy = node.y()

    group.on "dragend", (evt)->
        node = evt.targetNode
        node.setX(node.ox)
        node.setY(node.oy)
        shapesLayer.draw()


    shapesLayer.add group
    stage.add shapesLayer
    group
