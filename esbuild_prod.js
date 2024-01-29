import * as esbuild from 'esbuild'
import { solidPlugin } from 'esbuild-plugin-solid'

await esbuild.build({
  entryPoints: ['./frontend_src/app.jsx'],
  bundle: true,
  outfile: './app/assets/build/index.js',
  minify: true, 
  plugins: [solidPlugin()],
})

await esbuild.build({
  entryPoints: ['./frontend_src/auth/admin.jsx'],
  bundle: true,
  outfile: './app/assets/build/auth/admin.js',
  minify: true, 
  plugins: [solidPlugin()],
})
