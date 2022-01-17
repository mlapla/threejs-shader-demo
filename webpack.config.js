const path = require('path');

module.exports = {
  entry: {
    filename: './show.js'
  },
  output: {
    filename: 'threejs-tiling-shaders.bundle.js',
  },
  module: {
    rules: [{ test: /\.glsl$/, use: 'raw-loader' }],
  },
};