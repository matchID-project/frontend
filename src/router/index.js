import Vue from 'vue'
import Router from 'vue-router'
import Home from '@/components/Home'
// import Login from '@/components/Login'
import Project from '@/components/Project'
import Recipe from '@/components/Recipe'
import Dataset from '@/components/Dataset'
import ValidationController from '@/components/Validation/Controller'
import Jobs from '@/components/Jobs'

Vue.use(Router)

export default new Router({
  mode: 'history',
  routes: [
    {name: 'root', path: '/matchID', redirect: { name: 'home' }},
    // {name: 'home', path: '/matchID/login', component: Login},
    {name: 'home', path: '/matchID/projects', component: Home},
    {name: 'jobs', path: '/matchID/jobs', component: Jobs},
    {name: 'job', path: '/matchID/jobs/:job', component: Jobs},
    {name: 'project', path: '/matchID/projects/:project', component: Project},
    {name: 'recipe', path: '/matchID/projects/:project/recipes/:recipe', component: Recipe},
    {name: 'dataset', path: '/matchID/projects/:project/datasets/:dataset', component: Dataset},
    {name: 'validation', path: '/matchID/projects/:project/datasets/:dataset/validation', component: ValidationController}
  ]
})
