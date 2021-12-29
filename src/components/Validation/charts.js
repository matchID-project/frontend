import { Line } from 'vue-chartjs'
import chartjsPluginAnnotation from 'chartjs-plugin-annotation'

export default {
  extends: Line,
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
}
