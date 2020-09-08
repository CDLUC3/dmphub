const { environment } = require('@rails/webpacker')
const webpack = require('webpack')

environment.plugins.prepend('Provide',
  new webpack.ProvidePlugin({
    $: 'jquery/src/jquery',
    jQuery: 'jquery/src/jquery',
  })
);

environment.config.set('resolve.alias', {
  'jquery-ui': 'jquery-ui/ui/widgets/',
});

module.exports = environment
