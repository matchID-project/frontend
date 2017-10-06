<template>
  <div class="modal is-active ">
    <div class="modal-background" @click="close()"></div>
    <div class="column is-9">
      <div class="modal-content is-12">
        <div class="card">
          <div class="card-header">
            <div class="card-header-title" >
              <i class="fa fa-connectdevelop mID-margin-right-8" aria-hidden="true"></i> {{ localization.graph.title[lang] }}
              <span class="title is-4"> &nbsp; {{project}} </span>
            </div>
            <div class="card-header-icon">
              <button class="delete" @click="close()"></button>
            </div>
          </div>
          <div class="card-content has-text-centered">
            <div id="d3">
              <svg xmlns="http://www.w3.org/2000/svg"
                   :width="width+'px'"
                   :height="height+'px'"
                   @mousemove="drag($event)"
                   @mouseup="drop()"
                   v-if="bounds.minX">

                  <defs>
                    <template v-for="color in Object.keys(colors)">
<<<<<<< efbdf2fb4b5cc6ee0252ee83d00745a7b574aaa8
                      <marker  :id="'arrow-'+color" viewBox="0 0 20 15" refX="1" refY="5"
                          markerWidth="9" markerHeight="9" orient="auto"
=======
                      <marker  :id="'arrow-'+color" viewBox="0 0 10 10" refX="1" refY="5"
                          markerWidth="6" markerHeight="6" orient="auto"
>>>>>>> Linter (mostly removed trailing spaces)
                          >
                        <path :fill="colors[color]" d="M 5 0 L 20 5 L 5 10 z"  ></path>
                      </marker>
                      <marker  :id="'circle-'+color" viewBox="0 0 10 10" refX="5" refY="5"
                          markerWidth="10" markerHeight="10" orient="auto"
                          >
                        <circle :fill="colors[color]" cx="5" cy="5" r="3"  ></circle>
                      </marker>

                    </template>
                  </defs>

                <!-- <polyline v-for="link in links" v-show="linkStatus(link) !== 'hidden'"
                      :points="polyLineFromLink(link)"
                      :stroke="colors[linkStatus(link)]" 
                      :stroke-width="strokes[linkStatus(link)]"
                      :stroke-dasharray="strokeDasharray[linkStatus(link)]"
                      :marker-mid="'url(#' + markers[linkStatus(link)] + '-' + linkStatus(link) + ')'"
                      >
                </polyline> -->

<<<<<<< efbdf2fb4b5cc6ee0252ee83d00745a7b574aaa8
                <path v-for="link in links" v-show="linkStatus(link) !== 'hidden'"
                      :d="pathFromLink(link)"
                      :stroke="colors[linkStatus(link)]" 
=======
                <polyline v-for="link in links"
                      :points="coords[link.source.index].x + ',' + coords[link.source.index].y
                       + ' ' + (coords[link.source.index].x+coords[link.target.index].x)/2 + ',' + (coords[link.source.index].y+coords[link.target.index].y)/2
                       + ' ' + coords[link.target.index].x + ',' + coords[link.target.index].y"
                      :stroke="colors[linkStatus(link)]"
>>>>>>> Linter (mostly removed trailing spaces)
                      :stroke-width="strokes[linkStatus(link)]"
                      :stroke-dasharray="strokeDasharray[linkStatus(link)]"
                      :marker-mid="'url(#' + markers[linkStatus(link)] + '-' + linkStatus(link) + ')'"
                      fill="None"
                      >
                </path>

                <template v-for="(node, i) in nodes" >
                  <g :transform="'translate(' + coords[i].x + ',' + coords[i].y + ')'">
                    <title> {{node.type}}: {{node.name}}</title>
<<<<<<< efbdf2fb4b5cc6ee0252ee83d00745a7b574aaa8
                    <circle v-show="node.show"
                            :r="circles[nodeStatus(node)] * scale[nodeStatus(node)]" fill="white"
                            :stroke="colors[node.type]" 
=======
                    <circle
                            :cx="coords[i].x"
                            :cy="coords[i].y"
                            :r="circles[nodeStatus(node)]" fill="white"
                            :stroke="colors[node.type]"
>>>>>>> Linter (mostly removed trailing spaces)
                            :stroke-width="strokes[nodeStatus(node)]"
                            @mousedown="currentMove = {x: $event.screenX, y: $event.screenY, node: node}"
                            @click="toggle(node)"
                            >
                    </circle>
<<<<<<< efbdf2fb4b5cc6ee0252ee83d00745a7b574aaa8
                    <g class="transform-origin: center center">
                      <icon 
                            v-show="node.active"
                            :x="-7.5 * scale[nodeStatus(node)]"
                            :y="-7.5 * scale[nodeStatus(node)]"
                            :scale="scale[nodeStatus(node)]"
                            :name="icons[nodeStatus(node)]" 
                            :color="colors[nodeStatus(node)]"
                      >
                      </icon>
                    </g>
                    <text 
                      v-show="node.active"
                      :y="25 * scale[nodeStatus(node)]"
                      :fill="colors[node.type]"
                      class="is-small"
                      text-anchor="middle"
                      > 
=======
                  </g>
                  <icon
                        v-show="dynShow[node.name+node.type] === 'active'"
                        :name="icons[node.type]"
                        :x="coords[i].x-8"
                        :y="coords[i].y-8"
                        :color="colors[nodeStatus(node)]"
                  >
                  </icon>

                  <text
                    v-show="dynShow[node.name+node.type] === 'active'"
                    :x="coords[i].x"
                    :y="coords[i].y+25"
                    :fill="colors[node.type]"
                    class="is-small"
                    text-anchor="middle"
                    >
>>>>>>> Linter (mostly removed trailing spaces)

                            {{node.name}}
                    </text>
                  </g>
                </template>


              </svg>
            </div>

          </div>
          <div class="card-footer has-text-centered">
          </div>
        </div>
      </div>
    </div>
    <button class="modal-close is-large" @click="close()"></button>

  </div>
</template>

<script>
import * as d3 from 'd3'
import 'vue-awesome/icons'
import Icon from 'vue-awesome/components/Icon'

export default {
  components: {
    Icon
  },
  props: {
    datasets: Object,
    recipes: Object,
    project: String
  },
  data () {
    return {
      nodes: []
        // .concat([{name: this.project, type: 'project', props: { project: this.project }, x: this.width / 2, y: this.height / 2, fixed: false, rank: 0}])
        .concat(Object.keys(this.datasets).map((name, index) => ({name: name, type: 'dataset', show: (this.datasets[name].project === this.project), dbtype: this.datasets[name].connector, active: (this.datasets[name].project === this.project), x: this.width / 2, y: this.height / 2, fixed: false})))
        .concat(Object.keys(this.recipes).map((name, index) => ({name: name, type: 'recipe', active: (this.recipes[name].project === this.project), show: (this.recipes[name].project === this.project), x: this.width / 2, y: this.height / 2, fixed: false})))
        .concat(),
      links: [],
      width: Math.max(document.documentElement.clientWidth, window.innerWidth || 0) * 0.7,
      height: Math.max(document.documentElement.clientHeight, window.innerHeight || 0) * 0.7,
      padding: 80,
      detph: -1,
      coords: {},
      linkStrength: {
        'projectLink': 0.1,
        'link': 1,
        'recipeCall': 0.1,
        'join': 2,
        'ml': 2
      },
      scale: {
        'dataset': 1,
        'recipe': 1,
        'elasticsearch': 1.5,
        'ml': 1.5,
        'hidden': 1,
        'inactive': 1
      },
      collide: {
        'project': 5,
        'dataset': 15,
        'recipe': 15,
        'ml': 15,
        'inactive': 2,
        'hidden': 0
      },
      charge: {
        'project': -5,
        'dataset': -10,
        'recipe': -10,
        'ml': -10,
        'inactive': -2,
        'hidden': 0
      },
      markers: {
        'projectLink': 'arrow',
        'recipeCall': 'circle',
        'join': 'circle',
        'link': 'arrow',
        'ml': 'arrow',
        'inactive': null
      },
      colors: {
        'arrow': '#00d1b2',
        'project': '#00d1b2',
        'projectLink': '#00d1b2',
        'dataset': 'blue',
        'elasticsearch': 'blue',
        'recipe': 'green',
        'ml': 'red',
        'link': '#00d1b2',
        'join': 'red',
        'inactive': '#aaa',
        'hidden': '#fff',
        'recipeCall': '#00d1b2'
      },
      circles: {
        'project': 32,
        'dataset': 16,
        'recipe': 16,
        'elasticsearch': 16,
        'ml': 16,
        'inactive': 6
      },
      icons: {
        'project': 'industry',
        'dataset': 'table',
        'elasticsearch': 'database',
        'recipe': 'flask',
        'ml': 'magic'
      },
      strokeDasharray: {
        'projectLink': '0',
        'join': '0',
        'ml': '0',
        'recipeCall': '0',
        'link': '0',
        'inactive': '5,5'
      },
      strokes: {
        'link': 1.5,
        'join': 2,
        'ml': 2,
        'dataset': 1,
        'recipe': 1,
        'project': 2,
        'projectLink': 0.5,
        'recipeCall': 0.5,
        'inactive': 0.5
      },
      simulation: null,
      currentMove: null
    }
  },
  computed: {
    bounds () {
      return {
        minX: Math.min(...this.nodes.map(n => n.x)),
        maxX: Math.max(...this.nodes.map(n => n.x)),
        minY: Math.min(...this.nodes.map(n => n.y)),
        maxY: Math.max(...this.nodes.map(n => n.y))
      }
    }
  },
  created () {
    var vue = this
    this.links = this.createLinks()
    var links = this.links.map(l => Object.create(l))
    this.simulation = d3.forceSimulation(vue.nodes)
        .force('collide', d3.forceCollide(function (d) { return vue.collide[vue.nodeStatus(d)] }).iterations(16))
        .force('charge', d3.forceManyBody().strength(d => vue.charge[vue.nodeStatus(d)]))
        .force('link', d3.forceLink(links))
        // .force('center', d3.forceCenter().x(this.width * 0.5).y(this.height * 0.5))
        .force('y', d3.forceY())
        .force('x', d3.forceX())

    this.showLinkedNodes()
    this.computeRanks()
    this.computeCoords()
  },
  methods: {
    computeCoords () {
      this.coords = this.nodes.map(node => {
        var xConstraint = ((node.depth) / Math.max(1, this.depth - 1)) * (this.width - 2 * this.padding) + this.padding
        var yConstraint = (node.beam === undefined ? 1 : node.beam - 0.5) / Math.max(1, this.beam[node.depth]) * (this.height - this.padding)

        var c = {
          x: xConstraint,
          y: yConstraint
          // y: this.padding + (node.y - this.bounds.minY) * (this.height - 2 * this.padding) / (this.bounds.maxY - this.bounds.minY)
        }
        return c
      })
    },
    showLinkedNodes () {
      for (var node in this.nodes) {
        node = this.nodes[node]
        if (node.active === true) {
          node.show = true
        } else {
          node.show = false
          for (var link in this.links) {
            link = this.links[link]
            if (link.source.index === node.index) {
              this.nodes[link.source.index].show = this.nodes[link.source.index].show || link.target.active
            }
            if (link.target.index === node.index) {
              this.nodes[link.target.index].show = this.nodes[link.target.index].show || link.source.active
            }
          }
        }
      }
    },
    computeRanks () {
      // search for roots and leaves
      for (let n in this.nodes) {
        var node = this.nodes[n]
        n = node.index
        node.next = []
        node.previous = []
        var v = this.links.map(link => {
          if ((link.source.index === n) && this.nodes[link.source.index].show) {
            node.next.push(link.target.index)
            return [1, 0]
          }
          if ((link.target.index === node.index) && this.nodes[link.target.index].show) {
            node.previous.push(link.source.index)
            return [0, 1]
          }
          return [0, 0]
        }).reduce((a, b) => [Math.max(a[0], b[0]), Math.max(a[1], b[1]), a[0] + b[0], a[1] + b[1]])
        if (v[1] < v[0]) {
          node.root = true
          node.leave = false
          node.depth = 0
        } else if (v[1] > v[0]) {
          node.root = false
          node.leave = true
          node.depth = 1
        } else {
          node.root = false
          node.leave = false
          node.depth = 1
        }
        node.next = [...new Set(node.next)]
        node.previous = [...new Set(node.previous)]
      }

      // detect loops
      for (let n in this.nodes) {
        node = this.nodes[n]
        n = node.index
        node.loop = false
        var next = [...new Set(node.next)]
        let count = 0
        while ((!node.loop) && (next.length > 0) && (count < 10)) {
          next = [].concat.apply([], next.map(c => this.nodes[c].next))
          next = [...new Set(next.filter(n => (this.nodes[n].leave === false)))]
          if (next.includes(n)) {
            node.loop = true
          }
          count += 1
        }
      }

      // compute depths
      this.depth = 0
      var steps = 1
      var loopWarning = 0
      while ((steps > 0) && (loopWarning < 10)) {
        steps = 0
        for (let n in this.nodes) {
          let node = this.nodes[n]
          if ((node.depth === this.depth) && node.show) {
            for (var i in node.next) {
              var childIndex = node.next[i]
              let child = this.nodes['' + childIndex]
              if ((node.loop === true) && (child.loop === true) || (!child.show)) {
                this.nodes[childIndex].depth = this.depth + 1
              } else {
                this.nodes[childIndex].depth = Math.max(this.nodes[childIndex].depth, this.depth + 1)
                steps += 1
              }
            }
          }
        }
        loopWarning += 1
        this.depth += 1
      }
      this.depth += 1

      // beam (width) computation
      this.beam = {}
      for (var d = 0; d <= this.depth; d++) {
        var cBeam = 0
        for (let n in this.nodes) {
          this.beam[d] = 0
          node = this.nodes[n]
          if ((node.depth === d)) {
            if (node.show) {
              cBeam++
              node.beam = cBeam
            } else {
              node.beam = 1
            }
          }
        }
        this.beam[d] = cBeam
      }
      console.log(this.coords)
    },
    createLinks () {
      var links = []
      // project to objects
      // links = links.concat(Object.keys(this.recipes).map(i => ({ source: this.getNodeIndex(this.project, 'project'), target: this.getNodeIndex(i, 'recipe'), type: 'projectLink' })))
      // links = links.concat(Object.keys(this.datasets).map(i => ({ source: this.getNodeIndex(this.project, 'project'), target: this.getNodeIndex(i, 'dataset'), type: 'projectLink' })))

      // adds input dataset to recipe link
      links = links.concat(Object.keys(this.recipes).map(recipe => ({source: this.getNodeIndexFromRecipe(recipe, 'input'), target: this.getNodeIndex(recipe, 'recipe'), type: 'link'})))
      // adds output dataset to recipe link
      links = links.concat(Object.keys(this.recipes).map(recipe => ({source: this.getNodeIndex(recipe, 'recipe'), target: this.getNodeIndexFromRecipe(recipe, 'output'), type: 'link'})))

      // adds call from recipes to recipes
      for (var recipe in this.recipes) {
        console.log(this.recipes[recipe].project)
        if ((this.recipes[recipe].steps !== undefined) && (this.recipes[recipe].steps !== null)) {
          links = links.concat(this.recipes[recipe].steps.map(i => ({target: this.getNodeIndex(recipe, 'recipe'), source: this.getNodeIndex(Object.keys(i)[0], 'recipe'), type: 'recipeCall'})))
          // join to datasets
          links = links.concat(this.recipes[recipe].steps.filter(i => (Object.keys(i)[0] === 'join')).map(i => ({target: this.getNodeIndex(recipe, 'recipe'), source: this.getNodeIndex(i.join.dataset, 'dataset'), type: 'join'})))
          // ml models
          links = links.concat(this.recipes[recipe].steps.filter(i => (Object.keys(i)[0] === 'build_model')).map(i => ({source: this.getNodeIndex(recipe, 'recipe'), target: this.setNodeIndex(i.build_model.model.name, 'ml', this.recipes[recipe].project), type: 'ml'})))
          links = links.concat(this.recipes[recipe].steps.filter(i => (Object.keys(i)[0] === 'apply_model')).map(i => ({target: this.getNodeIndex(recipe, 'recipe'), source: this.setNodeIndex(i.apply_model.name, 'ml', this.recipes[recipe].project), type: 'ml'})))
        }
      }
      links = links.filter(l => this.testLink(l))
      // console.log(links)
      return links
    },
    polyLineFromLink (link) {
      var sourceNodeIndex
      var targetNodeIndex
      if (link.source.index !== undefined) {
        sourceNodeIndex = link.source.index
      } else {
        sourceNodeIndex = this.nodes[link.source].index
      }
      if (link.target.index !== undefined) {
        targetNodeIndex = link.target.index
      } else {
        targetNodeIndex = this.nodes[link.source].index
      }
      var c = {}
      c.source = this.coords[sourceNodeIndex]
      c.target = this.coords[targetNodeIndex]
      return this.polyline({x: c.source.x, y: c.source.y}, {x: c.target.x, y: c.target.y})
    },
    polyline (a, b) {
      var m = { x: (a.x + b.x) / 2, y: (a.y + b.y) / 2 }
      return a.x + ',' + a.y +
        ' ' + m.x + ',' + m.y +
        ' ' + b.x + ',' + b.y
        // m 12.121831,312.93054 c 54.548237,0 19.041686,14.05456 52.452326,14.05456 33.41064,0 7.651746,16.25002 41.996933,14.22971
    },
    pathFromLink (link) {
      var sourceNodeIndex
      var targetNodeIndex
      if (link.source.index !== undefined) {
        sourceNodeIndex = link.source.index
      } else {
        sourceNodeIndex = this.nodes[link.source].index
      }
      if (link.target.index !== undefined) {
        targetNodeIndex = link.target.index
      } else {
        targetNodeIndex = this.nodes[link.source].index
      }
      var a = this.coords[sourceNodeIndex]
      var b = this.coords[targetNodeIndex]

      var m
      if (a.x === b.x) {
        m = { x: a.x + 30, y: (a.y + b.y) / 2 }
        return 'M' + a.x + ',' + a.y +
          ' Q' + (a.x + 30) + ',' + a.y +
          ' ' + m.x + ',' + m.y +
          ' Q' + (b.x + 30) + ',' + b.y +
          ' ' + b.x + ',' + b.y
      } else {
        m = { x: (a.x + b.x) / 2, y: (a.y + b.y) / 2 }
        return 'M' + a.x + ',' + a.y +
          ' Q' + (a.x + (b.x - a.x) / 3) + ',' + a.y +
          ' ' + m.x + ',' + m.y +
          ' Q' + (b.x - (b.x - a.x) / 3) + ',' + b.y +
          ' ' + b.x + ',' + b.y
      }
    },
    testLink: function (link) {
      if (link === null) {
        return false
      }
      if ((link.source === null) || (link.target === null)) {
        return false
      }
      // if ((this.nodes[link.source] === undefined) || (this.nodes[link.target] === undefined)) {
      //   return null
      // }
      // if ((this.nodes[link.source] === null) || (this.nodes[link.target] === null)) {
      //   return null
      // }
      return true
    },
    toggle: function (node) {
      node.active = !node.active
      // update dependent nodes
      this.showLinkedNodes()
      this.computeRanks()
      this.computeCoords()
    },
    nodeStatus: function (node) {
      if (node.active) {
        if (node.type === 'dataset') {
          if (node.dbtype === 'elasticsearch') {
            return node.dbtype
          } else {
            return node.type
          }
        } else {
          return node.type
        }
      } else if (node.show) {
        return 'inactive'
      } else {
        return 'hidden'
      }
    },
    linkStatus: function (link) {
      var sourceNode = link.source
      var targetNode = link.target

      if ((sourceNode.active === true) && (targetNode.active === true)) {
        return link.type
      } else if ((sourceNode.active === true) || (targetNode.active === true)) {
        return 'inactive'
      } else {
        return 'hidden'
      }
    },
    close: function () {
      this.$emit('close')
    },
    setNodeIndex (name, type, project) {
      var i = 0
      for (var node in this.nodes) {
        if ((this.nodes[node].name === name) && (this.nodes[node].type === type)) {
          return i
        }
        i += 1
      }
      this.nodes.push({name: name, type: type, show: (project === this.project), active: (project === this.project), x: this.width / 2, y: this.height / 2, fixed: false})
      return this.nodes.length - 1
    },
    getNodeIndex (name, type) {
      var i = 0
      for (var node in this.nodes) {
        if ((this.nodes[node].name === name) && (this.nodes[node].type === type)) {
          return i
        }
        i += 1
      }
      return null
    },
    getDatasetNodeIndex (name) {
      for (var dataset in this.datasets) {
        if (dataset === name) {
          return this.getNodeIndex(dataset, 'dataset')
        }
      }
      return null
    },
    getNodeIndexFromRecipe (recipe, field) {
      recipe = this.recipes[recipe]
      if (recipe[field] === undefined) {
        return null
      } else if (typeof recipe[field] === 'string') {
        return this.getDatasetNodeIndex(recipe[field])
      } else if (recipe[field].dataset !== undefined) {
        return this.getDatasetNodeIndex(recipe[field].dataset)
      } else {
        return null
      }
    },
    drag (e) {
      if (this.currentMove) {
        this.currentMove.node.fx = this.currentMove.node.x - (this.currentMove.x - e.screenX) * (this.bounds.maxX - this.bounds.minX) / (this.width - 2 * this.padding)
        this.currentMove.node.fy = this.currentMove.node.y - (this.currentMove.y - e.screenY) * (this.bounds.maxY - this.bounds.minY) / (this.height - 2 * this.padding)
        this.currentMove.x = e.screenX
        this.currentMove.y = e.screenY
      }
    },
    drop () {
      delete this.currentMove.node.fx
      delete this.currentMove.node.fy
      this.currentMove = null
      this.simulation.alpha(1)
      this.simulation.restart()
    }
  }
}
</script>
