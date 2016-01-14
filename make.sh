#!/bin/sh
set -e

export PATH="/bin:/usr/bin:/sbin:/usr/sbin:$PATH"

make() {
    if [ ! -d dungeon ] ; then
        make_base
    fi
    make_challenges
}

check_deps() {
    if [ -z "$(which debootstrap)" ] || [ -z "$(which apg)" ] ; then
        apt-get install debootstrap
    fi
}

make_base() {
    check_deps

    # Setup system
    mkdir dungeon
    debootstrap jessie ./dungeon

    # Install programms
    chroot dungeon apt-get install \
        bash

    # Make users
    chroot dungeon /usr/sbin/useradd -m -s /bin/bash -U -p "password"   user
    chroot dungeon /usr/sbin/useradd -m -s /bin/bash -U -p "$(genname 1)" kikoo
}

make_challenges() {
    cd dungeon
    last_challenge=11
    i=0
    for name in $(genname $last_challenge | xargs echo) ; do
        echo $i
        challenge_$i "$name"
        i=$((i + 1))
    done
    cd ..
}

challenge_0() {
    cat >"home/user/README" <<EOF
    Hi, and welcome to that dungeon.

    You'll find many challenges in this system, the first one being right
    next to me. Although the first ordeals may seem easy, don't be fooled as
    it will quickly grow into a task worthy of your attention.

    Each challenge comes with a key that you'll have to find. You can check
    that you have found the right key with your administrator, although it
    should be fairly easy to know that it is indeed a true key.

    Nothing forces you to do the challenges in order, but you might find it
    easier that way.

    If you need any help don't hesitate asking for help, but do so only after
    having searched for yourself. Here is a holy manual, put it to great use.
    To read it call it with the name of what you want to know:

        $ man man

    Go now, and good luck.
EOF
}

challenge_1() {
    cat >"home/user/${1}_1" <<EOF
    Key 1: chocolate

    You'll find the number 2 at the root of all things.
EOF
}

challenge_2() {
    cat >"${1}_2" <<EOF
    Key 2: lollipop

    You'll find the number 3 hidden where you started
EOF
}

challenge_3() {
    cat >"home/user/.${1}_3" <<EOF
    Key 3: coffee

    You'll find the number 4 a steps above
EOF
}

challenge_4() {
    cat >"home/${1}_4" <<EOF
    Key 4: sushi

    You'll find the number 5 amongst kikoo's files
EOF
}

challenge_5() {
    cat >"home/kikoo/${1}_5" <<EOF
    Key 5: pizza

    The number 6 is where you'll find more
EOF
    cd home/kikoo
    for name in `genname 99` ; do
        touch "${name}_5"
    done
    cd ../..
}

challenge_6() {
    cat >"bin/${1}_6" <<EOF
    Key 6: banana

    The number 7 is next to the darkest hole
EOF
}

challenge_7() {
    cat >"dev/${1}_7" <<EOF
    Key 7: brownie

    The number 8 stands amongst countless heads
EOF
}

challenge_8() {
    cat >"usr/include/${1}_8" <<EOF
    Key 8: steak

    You'll find the number 9 right in his boots.
EOF
}

challenge_9() {
    cat >"boot/${1}_9" <<EOF
    Key 9: spaghetti

    The number 10 awaits you in the greatest library.
EOF
}

challenge_10() {
    cat >"usr/lib/${1}_10" <<EOF
    Key 10: carrot

    That's all for now, although many more challenges will come!
EOF
}

genname() {
    apg -Mcln -n $1
}

enter() {
    if [ ! -d dungeon ] ; then
        make
    fi
    chroot --userspec=user dungeon /bin/bash --rcfile "/home/user/.bashrc"
}

if [ -z "$1" ] ; then
    echo "Usage: $0 (make|enter)"
    exit 0
fi

if [ "$(whoami)" != "root" ] ; then
    exec sudo "$0" "$@"
else
    "$1"
fi
