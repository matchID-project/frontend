<template>
  <section class="is-fullheight">
    <div class="box is-marginless">
      <div class="field is-horizontal">
        <div class="field-body">
          <div class="field is-narrow">
            <div class="control">
              <div class="select is-small">
                <select v-model="pageSize">
                  <option
                    v-for="n in 10"
                    :value="50 * n"
                  >
                    {{50 * n}}
                  </option>
                </select>
              </div>
            </div>
          </div>
          <pagination
            :pageSize="pageSize"
            :lengthData="dataLength"
            :pageCurrent="pageCurrent"
            @pageChanged="v => {pageCurrent = v}"
          ></pagination>
          <!-- <div class="field is-narrow">
            <div class="control">
              <div class="select is-small">
                <select v-model="order">
                  <option
                    v-for="(order, key) in {rows: 'Rows first', columns: 'Columns first'}"
                    :value="key"
                  >
                    {{ order }}
                  </option>
                </select>
              </div>
            </div>
          </div> -->
          <div class="field">
            <p class="control is-expanded has-icons-left">
              <input
                v-model="colFilter"
                class="input is-small"
                type="text"
                :placeholder="localization.dataViewer.colFilter[lang]"
              >
              <span class="icon is-small is-left">
                <i class="fa fa-filter"></i>
              </span>
            </p>
          </div>
          <div class="field has-addons">
            <p class="control has-icons-left">
              <input
                v-model="rowSearch"
                class="input is-small"
                type="text"
                :placeholder="localization.dataViewer.rowSearch[lang]"
              >
              <span class="icon is-small is-left">
                <i class="fa fa-columns"></i>
              </span>
            </p>
            <p class="control is-expanded has-icons-left">
              <input
                v-model="search"
                class="input is-small"
                type="text"
                ref="search"
                :placeholder="localization.dataViewer.search[lang]"
                :autofocus="search === 'matchid_name_first_src'"
              >
              <span class="icon is-small is-left">
                <i class="fa fa-search"></i>
              </span>
            </p>
          </div>
        </div>
      </div>
    </div>

    <div class="is-overflowed" style="height: calc(100% - 53.375px)">
      <table class='table is-narrow is-bordered is-hoverable is-size-7'>
        <thead id="general-thead">
          <tr>
            <th class="has-background-white-ter is-paddingless is-fullheight" rowspan="2"></th>
            <th
              v-for="column in computedColumns"
              class="has-background-white-ter is-fullheight"
              :title="column.field"
              v-if="column.display"
              rowspan="1"
            >
              {{column.label}}
            </th>
          </tr>
          <tr>
            <th
              v-for="column in computedColumns"
              v-if="column.display"
              class="is-paddingless"
              rowspan="1"
            >
              <div class="card">
                <div class="card-footer">
                  <div class="card-footer-item" v-clipboard:copy="column.field">
                    <span class="icon is-small">
                      <i class="fa fa-copy"></i>
                    </span>
                  </div>
                  <div
                    class="card-footer-item"
                    @click="sortBy(column.field)"
                    :class="{'has-text-info' : sortKey == column.field}"
                  >
                    <span class="icon is-small">
                      <i
                        class="fa"
                        :class="sortOrders[column.field] > 0 ? 'fa-caret-up' : 'fa-caret-down'"
                      ></i>
                    </span>
                  </div>
                  <div class="card-footer-item" @click="rowSearch = column.field; $refs.search.focus()">
                    <span class="icon is-small">
                      <i class="fa fa-search" aria-hidden="true"></i>
                    </span>
                  </div>
                </div>
              </div>
            </th>
          </tr>
        </thead>
        <tbody class="one-line-table">
          <tr
            v-for="(entry, index) in computedData"
            :key="index"
          >
            <td class="has-text-centered is-size-7">
              <span class="icon is-small">
                <i class="fa fa-chevron-right"></i>
              </span>
            </td>
            <td
              v-for="column in computedColumns"
              :key="column.field"
              v-if="column.display"
            >
              {{ entry[column.field] }}
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </section>
</template>

<script>
import Pagination from './Helpers/Pagination'

export default {
  components: {
    Pagination
  },
  props: {
    data: Array,
    columns: Array
  },
  data () {
    let sortOrders = {}
    this.columns.forEach(key => {
      sortOrders[key] = 1
    })

    return {
      // filter & search
      order: 'columns',
      colFilter: '',
      rowSearch: '',
      search: '',
      // sorting
      sortKey: '',
      sortOrders: sortOrders,
      // pagination
      pageSize: 50,
      pageCurrent: 1,
      dataLength: 1
    }
  },
  computed: {
    computedColumns () {
      let cols = []
      this.columns.forEach(elem => {
        cols.push({
          label: elem.replace(/_/g, ' '),
          field: elem,
          display: this.colFilter ? Array.isArray(elem.match(this.colFilter)) : true
        })
      })
      return cols
    },
    computedData () {
      let sortKey = this.sortKey
      let filterKey = this.search && this.search.toLowerCase()
      let rowSearch = this.rowSearch
      let order = this.sortOrders[sortKey] || 1
      let data = this.data
      if (filterKey) {
        data = data.filter(row => {
          return Object.keys(row).some(key => {
            if (!rowSearch || (rowSearch && key.match(rowSearch))) return this.exists(filterKey, row[key])
            return false
          })
        })
      }
      if (sortKey) {
        data = data.slice().sort((a, b) => {
          a = a[sortKey]
          b = b[sortKey]
          return (a === b ? 0 : a > b ? 1 : -1) * order
        })
      }

      this.dataLength = data.length

      return data.slice((this.pageCurrent - 1) * this.pageSize, this.pageCurrent * this.pageSize)
    }
  },
  watch: {
    pageSize () {
      this.pageCurrent = 1
    }
  },
  methods: {
    sortBy (key) {
      this.sortKey = key
      this.sortOrders[key] = this.sortOrders[key] * -1
    },
    exists (key, word) {
      return String(word).toLowerCase().indexOf(key) > -1
    }
  }
}
</script>

<style lang="scss" scoped>
.one-line-table {
  white-space: nowrap;
}

.card-footer {
  cursor: pointer;
}

.card-footer-item {
  padding: 0.3rem;
}

</style>
