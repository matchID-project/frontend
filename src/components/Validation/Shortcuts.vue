<template>
  <div class="modal is-active">
    <div class="modal-background" @click="$emit('close')"></div>
      <div class="modal-content">
        <div class="card">
          <div class="card-header">
            <div class="card-header-title">
              <span class="icon">
                <i class="fa fa-keyboard-o" aria-hidden="true"></i>
              </span>
              {{ localization.validation.shortcuts.title[lang] }}
            </div>
            <div class="card-header-icon">
              <button class="delete" @click="$emit('close')"></button>
            </div>
          </div>
          <div class="card-content">
            <div class="box">
              <div class="columns level">
                <div class="column is-one-third has-text-centered">
                  <span class="tag is-medium">Ctrl</span>
                  <span class="tag is-medium is-white">+</span>
                  <span class="tag is-medium">Alt</span>
                </div>
                <div class="column is-two-thirds" v-html="localization.validation.shortcuts.activate_deactivate[lang]"></div>
              </div>
            </div>
            <div class="level">
              <h5 class="subtitle">{{localization.validation.shortcuts.only_when_activated[lang]}}</h5>
            </div>
            <div class="box" v-show="validationDisplay">
              <div class="columns level">
                <div class="column is-one-third has-text-centered">
                  <span class="tag is-medium">a</span>
                </div>
                <div class="column is-two-thirds" v-html="localization.validation.shortcuts.change_decision[lang]"></div>
              </div>
            </div>
            <div class="box" v-show="validationDisplay">
              <div class="columns level">
                <div class="column is-one-third has-text-centered">
                  <span class="tag is-medium">e</span>
                </div>
                <div class="column is-two-thirds" v-html="localization.validation.shortcuts.change_indecision[lang]"></div>
              </div>
            </div>
            <div class="box" v-show="validationDisplay">
              <div class="columns level">
                <div class="column is-one-third has-text-centered">
                  <span class="tag is-medium">Space</span>
                </div>
                <div class="column is-two-thirds" v-html="localization.validation.shortcuts.validate[lang]"></div>
              </div>
            </div>
            <div class="box">
              <div class="columns level">
                <div class="column is-one-third has-text-centered">
                  <span class="tag is-medium">
                    <span class="icon is-small"><i class="fa fa-arrow-up"></i></span>
                  </span>
                  <span class="tag is-medium is-white">/</span>
                  <span class="tag is-medium">
                    <span class="icon is-small"><i class="fa fa-arrow-down"></i></span>
                  </span>
                </div>
                <div class="column is-two-thirds" v-html="localization.validation.shortcuts.previous_next[lang]"></div>
              </div>
            </div>
            <div class="box">
              <div class="columns level">
                <div class="column is-one-third has-text-centered">
                  <span class="tag is-medium">i</span>
                </div>
                <div class="column is-two-thirds" v-html="localization.validation.shortcuts.reload_random[lang]"></div>
              </div>
            </div>
            <div class="box">
              <div class="columns level">
                <div class="column is-one-third has-text-centered">
                  <span class="tag is-medium">d</span>
                </div>
                <div class="column is-two-thirds" v-html="localization.validation.shortcuts.json_view[lang]"></div>
              </div>
            </div>
          </div>
        </div>
      </div>
    <button class="modal-close is-large" @click="$emit('close')"></button>
  </div>
</template>

<script>
export default {
  props: {
    'validationDisplay': {
      required: true,
      type: Boolean
    }
  }
}
</script>
