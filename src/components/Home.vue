<template>
  <div>
    <div class="hero">
      <section class="hero is-info">
        <div class="hero-body">
          <div class="container">
            <h1 class="title">
              LIST ALL PROJECTS
            </h1>
          </div>
        </div>
      </section>
    </div>
    <div class="box">
      <div class="container">
        <ul>
          <li v-for="project in projects" :key="project.key">
            <router-link :to="{ name: 'project', params: { project: project}}">
              {{ project }}
            </router-link>
          </li>
        </ul>
      </div>
    </div>
  </div>
</template>

<script>

export default {
  data () {
    return {
      projects: []
    }
  },
  created () {
    this.$http.get(this.apiUrl + '/conf')
      .then(response => {
        this.projects = Object.keys(response.body.projects)
      })
  }
}
</script>

<style lang="scss" scoped>
</style>
