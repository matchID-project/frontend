import { Line, mixins } from 'vue-chartjs'
// eslint-disable-next-line
import chartjsPluginAnnotation from 'chartjs-plugin-annotation'

export default Line.extend({
  mixins: [mixins.reactiveProp],
  props: {
    chartData: {
      required: true,
      type: Object
    },
    options: {
      type: Object
    }
  },
  mounted () {
    this.renderChart(this.chartData, this.options)
  }
})
