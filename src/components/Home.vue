<template>
  <section class="section" id="home">
    <div class="container">
      <div class="columns is-multiline is-9">
        <div class="column is-half" v-for="project in projects" :key="project.key">
          <router-link class="hero is-link box" :to="{ name: 'project', params: { project: project}}">
            <div class="hero-body">
              <div class="container">
                <h1 class="title">
                  {{ project }}
                </h1>
              </div>
            </div>
          </router-link>
        </div>
        <div class="column is-half">
          <a class="hero is-light box" @click="newObject = {display: true, type: 'project'}">
            <div class="hero-body">
              <div class="container">
                <h1 class="title">
                  <span class="icon mID-margin-right-8"><i class="fa fa-plus" aria-hidden="true"></i></span>
                  <span>{{ localization.object.new.project[lang] }}</span>
                </h1>
              </div>
            </div>
          </a>
        </div>
      </div>
    </div>

    <new-object
      :display="newObject.display"
      :type="newObject.type"
      @close="newObject.display = false"
    ></new-object>
  </section>
</template>

<script>
import NewObject from '@/components/Object/New.vue'

export default {
  components: {
    NewObject
  },
  data () {
    return {
      projects: [],
      // new object
      newObject: {
        display: false,
        type: null
      }
    }
  },
  created () {
    setTimeout(() => {
      if (this.projects.length === 0) {
        window.bus.$emit('reloadNav')
      }
    }, 2000)
    window.bus.$on('reloadProjects', (projects) => {
      this.projects = projects
    })
  }
}
</script>

<style lang="scss" scoped>
</style>
