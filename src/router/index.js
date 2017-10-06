import Vue from 'vue'
import Router from 'vue-router'
import Dataprep from '@/components/Dataprep'
import Home from '@/components/Home'
import Project from '@/components/Project'
import Recipe from '@/components/Recipe'
import Dataset from '@/components/Dataset'
import Validation from '@/components/Validation/Controller'

Vue.use(Router)

export default new Router({
  mode: 'history',
  routes: [
    {name: 'old', path: '/old', component: Dataprep},
    {name: 'root', path: '/', redirect: { name: 'home' }},
    {name: 'home', path: '/projects', component: Home},
    {name: 'project', path: '/projects/:project', component: Project},
    {name: 'recipe', path: '/projects/:project/recipes/:recipe', component: Recipe},
    {name: 'dataset', path: '/projects/:project/datasets/:dataset', component: Dataset},
    {name: 'validation', path: '/projects/:project/datasets/:dataset/validation', component: Validation},
  ]
})
