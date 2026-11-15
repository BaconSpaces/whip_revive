-- whip_revive settings page in /whip -> Settings
Whip.configPage({
    label = 'Revive (Admin)',
    settings = {
        {
            key = 'RestoreNeeds',
            type = 'bool',
            label = 'Refill Needs',
            help = 'Restore hunger and thirst to 100% on revive or heal.'
        },
        {
            key = 'RestoreArmour',
            type = 'int',
            min = 0,
            max = 100,
            unit = '%',
            label = 'Restored Armour',
            help = 'Armour given upon revive (0-100).'
        },
        {
            key = 'DefaultAreaRadius',
            type = 'number',
            min = 1.0,
            max = 100.0,
            step = 1.0,
            unit = 'm',
            label = 'Area Revive Radius',
            help = 'Default radius in metres for /revivearea.'
        },
    },
})
