get_data = ->
  year = $("#year").val()
  month = $("#month").val()
  entity_val = year + month
  requestURL = "http://capitolwords.org/api/1/phrases.json?callback=?"
  $.getJSON requestURL,
    apikey: "300e73b059eb4a45a4744795d1f071f7"
    entity_type: "month"
    entity_value: entity_val
    sort: "tfidf desc"
  , (data) ->
    d3_configure data
    return

  return
d3_configure = (data) ->
  fill = d3.scale.category10()
  w = 1280
  h = 900
  force = d3.layout.force().gravity(0.06).charge(-50).size([
    w *= 2 / 3
    h *= 2 / 3
  ])
  svgContainer = d3.select("#chart").append("svg:svg").attr("width", w).attr("height", h).attr("transform", "translate(" + w / 4 + "," + h / 3 + ")")
  svgContainer.append("svg:rect").attr("width", w).attr("height", h).style("stroke", "black").style("fill", "white").style "stroke-width", "3"
  d3.json data, (error, json) ->
    collide = (node) ->
      r = node.radius + 16
      nx1 = node.x - r
      nx2 = node.x + r
      ny1 = node.y - r
      ny2 = node.y + r
      (quad, x1, y1, x2, y2) ->
        if quad.point and (quad.point isnt node)
          x = node.x - quad.point.x
          y = node.y - quad.point.y
          l = Math.sqrt(x * x + y * y)
          r = node.radius + quad.point.radius
          if l < r
            l = (l - r) / l * .5
            node.x -= x *= l
            node.y -= y *= l
            quad.point.x += x
            quad.point.y += y
        x1 > nx2 or x2 < nx1 or y1 > ny2 or y2 < ny1
    force.nodes(data).start()
    node = svgContainer.selectAll(".node").data(data).enter().append("svg:g").attr("r", (d) ->
      (((d.tfidf * 100000) - 1) / (120 - 1) * 100) + 25
    ).attr("class", "node").call(force.drag)
    node.append("circle").attr("r", (d) ->
      (((d.tfidf * 100000) - 1) / (120 - 1) * 100) + 25
    ).attr("stroke", "black").attr("fill", (d, i) ->
      fill i % 3
    ).call force.drag
    node.append("text").text((d) ->
      d.ngram + " " + d.count
    ).attr "dx", (d) ->
      -20

    svgContainer.style("opacity", 1e-6).transition().duration(1000).style "opacity", 1
    force.on "tick", (e) ->
      q = d3.geom.quadtree(data)
      i = 0
      n = data.length
      q.visit collide(data[i])  while ++i < n
      node.attr "transform", (d) ->
        x = d.x
        y = d.y
        "translate(" + (x) + "," + (y) + ")"

      return

    return

  return
$(document).ready ->
  get_data()
  return

$(document).on "change", "#year", ->
  d3.select("svg").remove()
  get_data()
  return

$(document).on "change", "#month", ->
  d3.select("svg").remove()
  get_data()
  return
