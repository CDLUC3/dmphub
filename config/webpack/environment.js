const { environment } = require('@rails/webpacker')
const webpack = require('webpack')

environment.plugins.prepend('Provide',
  new webpack.ProvidePlugin({
    $: 'jquery/src/jquery',
    jQuery: 'jquery/src/jquery',
    autoComplete: '@tarekraafat/autocomplete.js/dist/js/autoComplete.min.js',
  })
);

module.exports = environment
