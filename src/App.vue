<template>
  <header>
    <MatchIdNavigation/>
  </header>
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
