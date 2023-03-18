<template>
  <div id="editor" class="is-fullheight" style="font-size: 12px">
    <Codemirror
      ref="myEditor"
      v-model:value="code"
      :options="editorOptions"
      @beforeChange="beforeCodeChange"
      @change="onEditorCodeChange"
      class="is-fullheight"
    />
    <a
      class="delete is-large"
      v-show="isFullScreen"
      @click="editor.setOption('fullScreen', false); isFullScreen = false"
      id="closeFullScreen"
    ></a>
  </div>
</template>

<script>
import Codemirror from 'codemirror-editor-vue3'

import 'codemirror/lib/codemirror.css'
import 'codemirror/mode/css/css.js'

import 'codemirror/addon/selection/active-line.js'
import 'codemirror/addon/dialog/dialog.js'
import 'codemirror/addon/dialog/dialog.css'
import 'codemirror/addon/search/searchcursor.js'
import 'codemirror/addon/search/search.js'

// keyMap
import 'codemirror/addon/edit/matchbrackets.js'

// foldGutter
import 'codemirror/addon/fold/foldgutter.css'
import 'codemirror/addon/fold/brace-fold.js'
import 'codemirror/addon/fold/comment-fold.js'
import 'codemirror/addon/fold/foldcode.js'
import 'codemirror/addon/fold/foldgutter.js'
import 'codemirror/addon/fold/indent-fold.js'
import 'codemirror/addon/fold/markdown-fold.js'
import 'codemirror/addon/fold/xml-fold.js'
import 'codemirror/addon/display/fullscreen.css'
import 'codemirror/addon/display/fullscreen.js'

export default {
  components: {
    Codemirror
  },
  props: {
    codeData: String,
    saveCode: Boolean,
    showFullScreen: Boolean
  },
  data () {
    return {
      code: this.codeData,
      editorOptions: {
        styleActiveLine: true,
        lineNumbers: true,
        line: true,
        foldGutter: true,
        styleSelectedText: true,
        gutters: ['CodeMirror-linenumbers', 'CodeMirror-foldgutter'],
        lineWrapping: false,
        showCursorWhenSelecting: true,
        tabSize: 2,
        extraKeys: {
          'F11': cm => {
            this.isFullScreen = !cm.getOption('fullScreen')
            cm.setOption('fullScreen', !cm.getOption('fullScreen'))
          },
          'Esc': cm => {
            if (cm.getOption('fullScreen')) cm.setOption('fullScreen', false)
            this.isFullScreen = false
          },
          'Tab': cm => {
            cm.replaceSelection(Array(cm.getOption('indentUnit') + 1).join(' '))
          }
        },
        mode: 'text/yaml',
        theme: 'rubyblue'
      },
      isFullScreen: false
    }
  },
  watch: {
    saveCode (newVal) {
      if (newVal) {
        this.$emit('codeSaved-' + this.$route.name, this.code)
      }
    },
    showFullScreen (newVal) {
      if (newVal) {
        this.isFullScreen = true
        this.editor.setOption('fullScreen', true)
        this.$emit('showedFullScreen')
      }
    }
  },
  computed: {
    editor () {
      return this.$refs.myEditor.editor
    }
  },
  methods: {
    beforeCodeChange (cm, change) {
      let readOnlyLines = [0, 1]
      if (~readOnlyLines.indexOf(change.from.line)) {
        change.cancel()
      }
    },
    onEditorCodeChange (newCode) {
      this.code = newCode
    }
  }
}
</script>

<style lang="scss">
.CodeMirror {
  height: 100%;
}
#closeFullScreen {
  z-index: 99;
  position: fixed;
  top: 0;
  right: 0;
}
</style>
