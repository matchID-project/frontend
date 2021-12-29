<template>
  <header>
    <MatchIdNavigation/>
  </header>
  <router-view></router-view>
</template>

<script>
import 'font-awesome/css/font-awesome.css';

import MatchIdNavigation from '@/components/Navigation.vue'

export default {
  name: 'app',
  components: {
    MatchIdNavigation
  }
}
</script>

<style lang="scss">
  @import "@/assets/scss/style.scss";
</style>
