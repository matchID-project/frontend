<template>

  <div>
    <div v-show="loading">
      <div id="loading-spinner" class="has-text-centered">
        <span class="icon is-large">
          <i class="fa fa-circle-o-notch fa-spin"></i>
        </span>
      </div>
    </div>

    <div v-show="!loading & !empty" class="viewdata">
      <div id="viewdata-header" class="viewdata-header">
        <div id="viewdata-search" class="viewdata-page">
          <form id="page">
            {{ localization.viewdata.page[lang] }} <input type="number" class="viewdata-input-number" min="1" name="page" v-model="pageNumber">
          </form>
        </div>
        &nbsp;
        <div id="viewdata-search" class="viewdata-search">
          <form id="search">
             <input name="query"
                    v-model="searchQuery"
                    :placeholder="localization.viewdata.filter[lang]"/>
          </form>
        </div>
        &nbsp;
        <div id="viewdata-columns-filter" class="viewdata-search">
          <form id="columnsFilter">
             <input name="columnsFilter"
                    v-model="columnsFilter"
                    :placeholder="localization.viewdata.columnsFilter[lang]" />
          </form>
        </div>
      </div>
      <div id="viewdata-table" class="viewdata-table">
        <grid
          :pageSize="pageSize"
          :pageNumber="pageNumber"
          :data="gridData"
          :columns="gridColumns"
          :columnsFilter="columnsFilter"
          :filter-key="searchQuery">
        </grid>
      </div>
    </div>
  </div>

</template>

<script>
import Grid from './Grid'
import apiConf from '../assets/json/backend.json'
let api = apiConf.api

export default {
  components: {
    Grid
  },
  data () {
    return {
      empty: true,
      searchQuery: '',
      columnsFilter: '',
      loading: false,
      pageNumber: 1,
      pageSize: 15,
      gridColumns: [],
      gridData: []
    }
  },
  methods: {
    loadData (object) {
      var vue = this
      var w = window
      vue.gridColumns = []
      vue.gridData = []
      vue.empty = true
      var name = Object.keys(object)[0]
      if (name === undefined) {
        return
      }
      var type = object[name].type
      var url = api.url + type + 's/' + name + '/'
      var method = 'post'
      // console.log(url)
      if (type === 'recipe') {
        if (object[name].running === true) {
          // if recipe is already running, we then take a look at the output
          if (object[name].output.dataset !== undefined) {
            url = api.url + 'datasets/' + object[name].output.dataset + '/'
          } else if (object[name].output !== undefined) {
            url = api.url + 'datasets/' + object[name].output + '/'
          } else {
            url = url + 'test'
            method = 'put'
          }
        } else {
          url = url + 'test'
          method = 'put'
        }
      }
      window.bus.$emit('loadingData', true)
      this.$http[method](url)
        .then(
          response => {
            if (response.body.data !== undefined) {
              vue.gridData = response.body.data
              if (vue.gridData[0] === undefined) {
                vue.gridData = [{result: 'empty result'}]
              }
              vue.empty = false
              vue.gridColumns = Object.keys(vue.gridData[0])
              w.bus.$emit('columnsChange', vue.gridColumns)
            }
            w.bus.$emit('loadingData', false)
            if (type === 'recipe' && object[name].running === false) {
              w.bus.$emit('logChange', response.body.log)
            }
          },
          response => {
            w.bus.$emit('loadingData', false)
          }
        )
    }
  },
  mounted () {
    var vue = this

    window.bus.$on('codeContentChange', this.loadData)

    window.bus.$on('loadingData', function (loading) {
      vue.loading = loading
    })

    window.bus.$on('objectChange', this.loadData)
  }
}

</script>
