
// const PurgecssPlugin = require('purgecss-webpack-plugin')
// const glob = require('glob-all')
const path = require('path')

module.exports = {
  publicPath: `/${process.env.APP_NAME}/`,
  outputDir: 'dist',
  runtimeCompiler: true,
  productionSourceMap: true,
  lintOnSave: process.env.NODE_ENV !== 'production',
  devServer: {
    public: 'http://0.0.0.0/',
    overlay: true,
    host: '0.0.0.0',
    port: process.env.VUE_FRONTEND_DEV_PORT,
    hot: true,
    disableHostCheck: true,
    watchOptions: {
      poll: true
    }
  },
  configureWebpack: {
    // Merged into the final Webpack config
    plugins: [
      // new PurgecssPlugin({
      //   paths: glob.sync([
      //     path.join(__dirname, './public/index.html'),
      //     path.join(__dirname, './src/**/*.vue'),
      //     path.join(__dirname, './src/**/*.js')
      //   ]),
      //   whitelistPatterns: [
      //     /fa\-(motorcycle|truck|car|certificate|cog)/,
      //     /fa\-(minus\-circle|warning|life\-ring|spinner|spin|question\-circle|arrow\-left)/,
      //     /alert\-(info|danger|warning|success)/
      //   ]
      // })
    ]
  },
  pluginOptions: {
    lintStyleOnBuild: false,
    stylelint: {},
  },
}
