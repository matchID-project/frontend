<template>
  <header>
    <MatchIdNavigation/>
  </header>
  <router-view></router-view>
</template>

<script>
import 'bulma/css/bulma.css'
import MatchIdNavigation from '@/components/Navigation.vue'

export default {
  name: 'app',
  components: {
    MatchIdNavigation
  }
}
</script>
