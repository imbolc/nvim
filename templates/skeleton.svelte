<svelte:head>
    <title></title>
</svelte:head>

<script context="module">
    export async function preload (page, session) {
        try {
            let r = await this.fetch(session.origin + `/api/foo`)
            return r.ok ? r.json() : this.error(r.status, r.statusText)
        } catch (e) {
            return this.error(503, "Check your network connection")
        }
    }
</script>

<script>
    export let items
</script>

<style>
</style>
