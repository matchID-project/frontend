<template>
  <div id="editor" class="is-fullheight" style="font-size: 12px">
    <PrismEditor
      class="language-yaml is-fullheight"
      v-model="code"
      :highlight="highlighter"
      :options="editorOptions"
      @beforeChange="beforeCodeChange"
      @change="onEditorCodeChange"
      line-numbers
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

  import { PrismEditor } from 'vue-prism-editor';
  import 'vue-prism-editor/dist/prismeditor.min.css'; // import the styles somewhere
  import { highlight, languages } from 'prismjs/components/prism-core';
  import 'prismjs/components/prism-yaml';
  import 'prismjs/themes/prism-tomorrow.css'; // import syntax highlighting styles



export default {
  components: {
    PrismEditor
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
    },
  },
  computed: {
    editor () {
      return this.$refs.myEditor.editor
    }
  },
  methods: {
    highlighter(code) {
      return highlight(code, languages.yaml); // languages.<insert language> to return html with markup
    },
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
