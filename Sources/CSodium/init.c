extern int sodium_init(void);

__attribute__((constructor))
static void init()
{
    sodium_init();
}
