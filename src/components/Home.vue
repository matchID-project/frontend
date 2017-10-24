<template>
  <section class="section" id="home">
    <div class="container">
      <div class="columns is-multiline is-9">
        <div class="column is-half" v-for="project in projects" :key="project.key">
          <router-link :to="{ name: 'project', params: { project: project}}">
            <section class="hero is-primary box">
              <div class="hero-body">
                <div class="container">
                  <h1 class="title">
                    {{ project }}
                  </h1>
                </div>
              </div>
            </section>
          </router-link>
        </div>
      </div>
    </div>
  </section>
</template>

<script>
export default {
  data () {
    return {
      projects: []
    }
  },
  created () {
    this.$http.get(this.apiUrl + 'conf')
      .then(response => {
        this.projects = Object.keys(response.body.projects)
      })
  }
}
</script>

<style lang="scss" scoped>
</style>
