const path = require('path');

module.exports = {
  entry: {
    filename: './threejs-tiling-shaders.js'
  },
  output: {
    filename: 'threejs-tiling-shaders.bundle.js',
  },
  module: {
    rules: [{ test: /\.glsl$/, use: 'raw-loader' }],
  },
};